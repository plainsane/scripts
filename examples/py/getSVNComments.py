#!/usr/bin/python
import optparse
import os
import pysvn
import sys
import time

changeSetHashString = "%s@%s:%s-%s"
authCount = 0
class SVNRev:
    def __init__(self, low, high):
        self.low = low
        self.high = high

    def __eq__(self, value):
        if type(value) == int:
            return value >= self.low and value <= self.high
        elif isinstance(value, SVNRev) == True:
            return value.low == self.low and value.high == self.high
        else:
            raise ValueError, "can only compare with int and SVNRev types"

    def __str__(self):
        return "%d-%d" % (self.low, self.high)

    def __repr__(self):
        return self.__str__()

def getLogin(realm, username, may_save):
    raise SystemError, "Must supply a user and password"

def notify(event):
    print event

def cleanString(s):
    while s.find('  ') != -1:
        s = s.replace('  ', ' ')
        s = s.replace('\t', ' ')
        s = s.replace('\n', ' ')
    return s

# def getMergeBranches(info):
#     branches = {}
#     start = info.find('Property changes on: .')
#     info = info[start:]
#     start = info.find(': svn:mergeinfo')
#     end = info.find('\n', start)
#     info = info[end:]
#     for merge in info.split('\n'):
#         start = merge.find("/")
#         if start == -1:
#             continue
#         merge = merge[start:]
#         branch, revision = merge.split(':')
#         branch = branch.strip()
#         for rev in revision[1:].split(','):
#             revs = rev.split('-')
#             branches[branch] = []
#             if len(revs) == 1:
#                 rev = int(revs[0])
#                 rev = SVNRev(rev, rev)
#             else:
#                 rev = map(int, revs)
#                 rev = SVNRev(rev[0], rev[1])
#             branches[branch].append(rev)
#     return branches

def getMergeBranches(old, new):
    '''im sick of the documentation not helping me out, im putting this in on "just finish it" fuel.
    dirty as balls but it works'''
    diffs = {}
    for key in new:
        if old.has_key(key) == False:
            diffs[key] = new[key]
        else:
            for val in new[key]:
                if val not in old[key]:
                    if diffs.has_key(key) == False:
                        diffs[key] = []
                    diffs[key].append(val)
    return diffs

def getCommentsFromRepo(output, ignoreChangeSets, client, ignoreUrls, baseUrl, repoUrl, startRev, endRev, peg, topLevel = False):
    #we have to ignore the branch we are based off of and the branch we are following unless we are the top level call 
    #because then we have to follow ourself anyways...we are tring to keep from dropping in a bunch of duplicat comments.
    if topLevel == False and repoUrl in ignoreUrls:
        print >>sys.stderr, "skipping %s because it is in the ignore list" % repoUrl
        return 

    changeHash = changeSetHashString % (repoUrl, peg, startRev, endRev, )
    if ignoreChangeSets.has_key(changeHash):
        print >>sys.stderr, "skipping changeset %s for reason '%s'" % (changeHash, ignoreChangeSets[changeHash])
        return 
    else:
        ignoreChangeSets[changeHash] = "fetched"
        print 'fetching %s at %s to %s pegged %s' % (repoUrl, startRev, endRev, peg)

    if peg is None:
        peg = pysvn.Revision( pysvn.opt_revision_kind.unspecified )
    else:
        peg = pysvn.Revision( pysvn.opt_revision_kind.number, peg)
    revStart = pysvn.Revision(pysvn.opt_revision_kind.number, startRev)
    revEnd = pysvn.Revision(pysvn.opt_revision_kind.number, endRev)
    propDiffStart = revStart
    comments = client.log(repoUrl, strict_node_history=False, revision_start=revStart, revision_end=revEnd, peg_revision=peg)
    for comment in comments:
        if topLevel == True:
            print >>output, '########################revision:%d########################' % (comment['revision'].number,)
        #lets see if other changesets were merged in and if so, go to that branch and pull the comments
        if comment['revision'].number != propDiffStart.number:
            print comment['revision'].number, propDiffStart.number
            try:
                oldMerge = client.propget('svn:mergeinfo', repoUrl, revision=propDiffStart)
                oldMerge = parseMergeInfo(oldMerge[repoUrl])

                newMerge = client.propget('svn:mergeinfo', repoUrl, revision=comment['revision'])
                newMerge = parseMergeInfo(newMerge[repoUrl])

                branches = getMergeBranches(oldMerge, newMerge)
            except pysvn.ClientError, e:
                print str(e)
                #maybe the branch that was merged on did not have a previous version to diff the mergeinfo property
                branches = {}

            print branches
            for branch in branches:
                branchUrl = "%s%s" % (baseUrl, branch)
                if branchUrl in ignoreUrls:
                    print >>sys.stderr, "skipping merge from url %s because it's to be ignored (base line most likely)" % branchUrl
                    continue
                for rev in branches[branch]:
                    getCommentsFromRepo(output, ignoreChangeSets, client, ignoreUrls, baseUrl, branchUrl, rev.low,
                                            rev.high, rev.high)
            propDiffStart = comment['revision']

        if topLevel == False:
            print >>output, "####%s####" % (changeHash,)
        for line in comment['message'].split('\n'):
            line = cleanString(line)
            if line == '':
                continue
            elif line.find('svn merge') == -1:
                print >>output, line
        if topLevel == True:
            print >>output, '#########################################################'

def parseMergeInfo(data):
    info = {}
    for line in data.split('\n'):
        branch, revision = line.split(':')
        info[branch] = []
        for rev in revision.split(','):
            if rev.find('-') != -1:
                low, high = map(int, rev.split('-'))
                info[branch].append(SVNRev(low, high))
            else:
                low = int(rev)
                info[branch].append(SVNRev(low, low))
    return info

def getLowRev(rev):
    if type(rev) == int:
        return rev
    else:
        return rev.low

def getOpts():
    op = optparse.OptionParser(prog='svn log fetcher')
    op.add_option('-r', '--root', default='svn://svn.reflex/adytum', type='str', help='the svn repo', dest='root')
    op.add_option('-b', '--base', type='str', help='the base release to fetch comment delta from', dest='base')
    op.add_option('-x', '--release', type='str', help='The new release to collect comments for', dest='release')
    op.add_option('-u', '--user', type='str', help='svn user account to use', dest='user')
    op.add_option('-p', '--password', type='str', help='svn password to use', dest='password')
    op.add_option('-f', '--output', type='str', help='file to write the comments to', dest='file')

    options, args = op.parse_args()
    return options

def cleanPath(path):
    if path[0] != '/':
        path = '/%s' % path
    if path[-1] == '/':
        return path[0:-1]
    else:
        return path

def getBranchPoint(client, url):
    comments = client.log(url, discover_changed_paths=True)
    lastComment = None
    for comment in comments:
        lastComment = comment
    if lastComment is None:
        raise SystemError, "%s is not a branch" % url
    for change in lastComment.changed_paths:
        if change['action'] == 'A':
            if change['copyfrom_path'] is not None:
                return change['copyfrom_path'], change['copyfrom_revision'].number

if __name__ == "__main__":
    opts = getOpts()
    comments = file(opts.file, 'w')
    svnclient = pysvn.Client()
    svnclient.set_default_username(opts.user)
    svnclient.set_default_password(opts.password)
    svnclient.callback_get_login = getLogin
    svnclient.callback_notify = notify

    opts.base = cleanPath(opts.base)
    opts.release = cleanPath(opts.release)

    if opts.root[-1] == '/':
        opts.root = opts.root[0:-1]

    basePath = "%s%s" % (opts.root, opts.base)
    releasePath = "%s%s" % (opts.root, opts.release)
    #make sure the 2 branches share an ancestor...if not this is a very different script for another day
    releaseAncestor, releaseAncestorRev = getBranchPoint(svnclient, releasePath)
    if releaseAncestor == opts.base:
        baseAncestor = opts.base
        baseAncestorRev = releaseAncestorRev
    else:
        baseAncestor, baseAncestorRev = getBranchPoint(svnclient, basePath)
    if baseAncestor != releaseAncestor:
        raise SystemError, "cant perform diff because the two projects do not share the same parent.\n base:%s\nrelase:%s" %\
                            (baseAncestor, releaseAncestor)

    releaseAncestorRev = svnclient.info2(releasePath, recurse=False)[0][1]['last_changed_rev'].number
    basePath = "%s%s" % (opts.root, baseAncestor)
    #now we need to walk the common path between the 2 branches
    followPath = releasePath
    rev = pysvn.Revision( pysvn.opt_revision_kind.number, baseAncestorRev)
    baseLineMergeInfo = svnclient.propget('svn:mergeinfo', basePath, revision=rev, peg_revision=rev)
    baseLineMergeInfo = parseMergeInfo(baseLineMergeInfo[basePath])
#     baseRev = baseLineMergeInfo[opts.release][0].low
    baseRev = baseAncestorRev
    maxRev = releaseAncestorRev
    #we want to ignore ourselves because ppl will merge code from these branches onto their own, then reintegrate so we do not
    #want to chase these down and generate duplicate comments.
    ignoreUrls = [followPath, basePath, releasePath]
    ignoreChangeSets = {}
    #we need to build up a list of change sets that came from our base line branch so that we do not include those in our 
    #list of changes when walking other branches that may have included those change sets as well.
    for merge in baseLineMergeInfo:
        url = "%s%s" % (opts.root, merge)
        for rev in baseLineMergeInfo[merge]:
            changeHash = changeSetHashString % (url, rev.high, rev.low, rev.high, )
            ignoreChangeSets[changeHash] = 'baseline'
    print 'Building change document for %s from' % followPath, baseRev, 'to', maxRev
    getCommentsFromRepo(comments, ignoreChangeSets, svnclient, ignoreUrls, opts.root, followPath, baseRev, maxRev, maxRev, topLevel=True)

