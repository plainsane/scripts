import lxml.etree as etree
import sys

parser = etree.XMLParser(remove_blank_text=True)
x = etree.fromstring(sys.stdin.read(), parser=parser)
sys.stdout.write(etree.tostring(x, pretty_print = True))

