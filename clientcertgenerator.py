import os, pathlib                                                                       
import pyinotify, logging


logging.basicConfig(level=logging.INFO, format='%(asctime)s :: %(levelname)s :: %(message)s', filename='/var/log/mqttcertificates.log')

incoming='/srv/sftp/incoming_requests/'
outgoing='/srv/sftp/outgoing_certificates/'

WATCH_FOLDER = os.path.expanduser(incoming)                                          

#Checks for any changes in the sftp/incoming_requests folder
class EventHandler(pyinotify.ProcessEvent):                                     
    def process_IN_CLOSE_WRITE(self, event):                                    
        """                                                                    
        Writtable file was closed.                                              
        """                                                                     
        if event.pathname.endswith('.csr') and pathlib.Path(event.pathname).exists():
            fname = event.name.rpartition('.')
            client_csr = incoming + fname[0] + ".csr"
            client_crt = outgoing + fname[0] + ".crt"                                    
            print(fname[0])
            #generates certificate from client's signature request and drops the certificate in sftp/outgoing_certificates folder
            os.system("openssl x509 -req -in " + client_csr + " -CA /etc/mqtt/ca.crt -CAkey /etc/mqtt/ca.key -CAcreateserial -passin file:/etc/mqtt/passwordfile -out " + client_crt +" -days 356\nrm " + client_csr)
            logging.info("Certificate for " + fname[0] + " has ben generated")


    def process_IN_MOVED_TO(self, event):                                       
        """                                                                     
        File/dir was moved to Y in a watched dir (see IN_MOVE_FROM).            
        """                                                                     
        if event.pathname.endswith('.csr') and pathlib.Path(event.pathname).exists():                                     
            fname = event.name.rpartition('.')
            client_csr = incoming + fname[0] + ".csr"
            client_crt = outgoing + fname[0] + ".crt"                                      
            print(fname[0])                                            
            os.system("openssl x509 -req -in " + client_csr + " -CA /etc/mqtt/ca.crt -CAkey /etc/mqtt/ca.key -CAcreateserial -passin file:/etc/mqtt/passwordfile -out " + client_crt +" -days 356\nrm " + client_csr)
            logging.info("Certificate for " + fname[0] + " has ben generated")

    def process_IN_CREATE(self, event):                                         
        """                                                                     
        File/dir was created in watched directory.                              
        """                                                                     
        if event.pathname.endswith('.csr') and pathlib.Path(event.pathname).exists():                                     
            fname = event.name.rpartition('.')                                     
            client_csr = incoming + fname[0] + ".csr"
            client_crt = outgoing + fname[0] + ".crt" 
            print(fname[0])                                             
            os.system("openssl x509 -req -in " + client_csr + " -CA /etc/mqtt/ca.crt -CAkey /etc/mqtt/ca.key -CAcreateserial -passin file:/etc/mqtt/passwordfile -out " + client_crt +" -days 356\nrm " + client_csr)
            logging.info("Certificate for " + fname[0] + " has ben generated")

def main():                                                                     
    # watch manager                                                             
    mask = pyinotify.IN_CREATE | pyinotify.IN_MOVED_TO | pyinotify.IN_CLOSE_WRITE
    watcher = pyinotify.WatchManager()                                          
    watcher.add_watch(WATCH_FOLDER,                                             
                      mask,                                                     
                      rec=True)                                                 
    handler = EventHandler()                                                    
    # notifier                                                                  
    notifier = pyinotify.Notifier(watcher, handler)                             
    notifier.loop()                                                             
                                                     
main()   