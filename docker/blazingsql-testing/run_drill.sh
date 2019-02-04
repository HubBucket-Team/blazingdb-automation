#!/bin/bash
#nvidia-docker exec -it bzsqlcontainer /bin/bash
#cd /home/edith/blazingdb/apache-drill-1.12.0/bin/
#./drill-embedded

#OLD
#nvidia-docker exec -it bzsqlcontainer  /home/edith/blazingdb/apache-drill-1.12.0/bin/drill-embedded


#NEW
nvidia-docker exec -it -d bzsqlcontainer  /home/edith/blazingdb/apache-drill-1.12.0/bin/drill-embedded