#!/usr/bin/env python

import socket, threading, time

def handle(s):
    print repr(s.recv(4096))
    s.send('''
HTTP/1.1 101 Web Socket Protocol Handshake\r
Upgrade: WebSocket\r
Connection: Upgrade\r
WebSocket-Origin: http://localhost:8888\r
WebSocket-Location: ws://localhost:9876/\r
WebSocket-Protocol: sample
    '''.strip() + '\r\n\r\n')
    time.sleep(2)
  # s.send('\x00hello\xff')
    s.send('\x00000\xff')
#    s.send('\x00011\xff')
#    s.send('\x00102\xff')
#    s.send('\x00111\xff')
#    s.send('\x00201\xff')
#    s.send('\x00212\xff')
#    s.send('\x00300\xff')
#    s.send('\x00311\xff')
#    s.send('\x00411\xff')
#    time.sleep(2)
    s.close()
s = socket.socket()
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('', 9876));
s.listen(1);
while 1:
    t,_ = s.accept();
    #threading.Thread(target = handle, args = (t,)).start()
    handle(t)
