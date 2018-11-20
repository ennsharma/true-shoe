from http.server import BaseHTTPRequestHandler, HTTPServer
from threading import Thread

import socketserver
import json
import cgi
import random
import sched, time

class ScrapingHTTPServer(HTTPServer):
    scrape_interval = 5 # scrape USPS once every 10 seconds

    def __init__(self, server_address, handler_class):
        super(ScrapingHTTPServer, self).__init__(server_address, handler_class)

        self.tracked_packages = set()
        self.scheduler = sched.scheduler(time.time, time.sleep)

        # scrape USPS once every scrape_interval seconds, in a separate thread
        self.scheduler.enter(self.scrape_interval, 1, self._update_deliveries)
        self.scraping_thread = Thread(target = self.scheduler.run)
        self.scraping_thread.start()

    def _update_deliveries(self):
        print("Updating deliveries at time t=%s" %time.time())
        delivered_packages = []
        for package_number in self.tracked_packages:
            if self._is_delivered(package_number):
                # TODO: poke SneakerTransferContract with delivery update
                delivered_packages.append(package_number)

        for package_number in delivered_packages:
            self.tracked_packages.remove(package_number)

        # schedule next update
        self.scheduler.enter(self.scrape_interval, 1, self._update_deliveries)

    def _is_delivered(self, tracking_number):
        # TODO: Add actual USPS site scraper. For now, flips a coin to determine delivery status :)
        if random.random() > 0.5:
            return True
        return False

class Server(BaseHTTPRequestHandler):

    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()        

    def do_HEAD(self):
        self._set_headers()

    def do_GET(self):
        self._set_headers()
        self.wfile.write(json.dumps({'remaining_deliveries': list(self.server.tracked_packages)}).encode('utf-8'))
        
    def do_POST(self):
        ctype, pdict = cgi.parse_header(self.headers.get('content-type'))
        
        # refuse to receive non-json content
        if ctype != 'application/json':
            self.send_response(400)
            self.end_headers()
            return
            
        # read the message and convert it into a python dictionary
        length = int(self.headers.get('content-length'))
        message = json.loads(self.rfile.read(length))
        
        carrier = message['delivery_carrier']
        tracking_number = message['tracking_number']

        # verify carrier
        if carrier != 'USPS':
            self.send_response(412)
            self.end_headers()
            return
        
        # add the tracking number to the list of packages we track
        self.server.tracked_packages.add(tracking_number)

        # send response
        self._set_headers()
        self.wfile.write(json.dumps({'received': 'ok'}).encode('utf-8'))
        
def run(server_class=ScrapingHTTPServer, handler_class=Server, port=8008):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)

    print('Starting httpd on port %d...' % port)
    httpd.serve_forever()
    
if __name__ == "__main__":
    from sys import argv
    
    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()