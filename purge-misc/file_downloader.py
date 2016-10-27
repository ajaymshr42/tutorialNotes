import urllib2

url = "http://download.fztvseries.mobi/videos/TV/Friends%20With%20Better%20Lives/Season%201/Friends_With_Better_Lives_-_S01E02_-_Window_Pain.avi"
file_name = url.split('/')[-1]
u = urllib2.urlopen(url)
f = open(file_name, 'wb')
meta = u.info()
file_size = int(meta.getheaders("Content-Length")[0])/1024.0/1024.0
print "Downloading: %s MB: %s" % (file_name, file_size)

file_size_dl = 0
block_sz = 100000
while True:
    buffer = u.read(block_sz)
    if not buffer:
        break

    file_size_dl += len(buffer)
    f.write(buffer)
    status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
    status = status + chr(8)*(len(status)+1)
    print status,

f.close()