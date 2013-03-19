class a(object):
    def __init__(self):
        super(a, self).__init__()
        print 'made it to a'

class b(object):
    def __init__(self):
        super(b, self).__init__()
        print 'made it to b'

class ab(a,b):
    def __init__(self):
        super(ab, self).__init__()
        print 'made it to ab'

c = ab()
