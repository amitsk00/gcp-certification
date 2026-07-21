# create VPC and Subnet

gcloud compute networks create privatenet \
    --project=qwiklabs-gcp-02-9bdc204fb785 \
    --subnet-mode=custom \
    --mtu=1460 --bgp-routing-mode=regional 

gcloud compute networks subnets create privatesubnet-us \
    --project=qwiklabs-gcp-02-9bdc204fb785 \
    --range=172.16.0.0/24 \
    --stack-type=IPV4_ONLY \
    --network=privatenet \
    --region=us-east1

gcloud compute networks subnets create privatesubnet-eu \
    --network=privatenet \
    --region=europe-west1 \
    --range=172.20.0.0/20    


# firewall rulw

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
    --project=qwiklabs-gcp-02-9bdc204fb785 \
    --direction=INGRESS \
    --priority=1000 \
    --network=privatenet \
    --action=ALLOW \
    --rules=tcp:22,tcp:3389,icmp \
    --source-ranges=0.0.0.0/0 


# VM

gcloud compute instances create privatenet-us-vm \
    --zone="us-east1-b" \
    --machine-type=e2-micro \
    --subnet=privatesubnet-us


# routing across subnets

sudo ip route add 10.132.0.0/24 via 172.16.0.1 dev ens4




# Instace Template

gcloud compute instance-templates create us-central1-template \
    --project=qwiklabs-gcp-03-483cabc688c8 \
    --machine-type=e2-micro \
    --network-interface=network-tier=PREMIUM,subnet=default \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=467578865839-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --region=us-central1 \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=us-central1-template,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230509,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any \
    --metadata=enable-oslogin=true,startup-script-url="gs://cloud-training/gcpnet/httplb/startup.sh" \
    

# Managed Instance Group

gcloud beta compute instance-groups managed create us-central1-mig \
    --project=qwiklabs-gcp-03-483cabc688c8 \
    --base-instance-name=us-central1-mig \
    --size=1 \
    --template=us-central1-template \
    --zones=us-central1-c,us-central1-f,us-central1-b \
    --target-distribution-shape=EVEN --instance-redistribution-type=PROACTIVE \
    --list-managed-instances-results=PAGELESS \
    --no-force-update-on-repair

gcloud beta compute instance-groups managed set-autoscaling us-central1-mig \
    --project=qwiklabs-gcp-03-483cabc688c8 \
    --region=us-central1 \
    --cool-down-period=60 \
    --max-num-replicas=2 --min-num-replicas=1 \
    --mode=on \
    --target-cpu-utilization=0.8

# GKE


gcloud beta container clusters create orca-cluster-827 \
    --enable-private-nodes \
    --enable-private-endpoint \
    --enable-ip-alias \
    --enable-master-authorized-networks \
    --master-ipv4-cidr 172.16.0.32/28 \
    --network orca-build-vpc \
    --subnetwork orca-build-subnet \
    --zone us-east1-b \
   --service-account=orca-private-cluster-947-sa@qwiklabs-gcp-03-64db7af0e571.iam.gserviceaccount.com
    
gcloud compute instances describe orca-jumphost --zone us-east1-b | grep natIP
gcloud compute instances describe orca-jumphost --zone us-east1-b | grep natIP | awk '{print $2}'
EXT_IP=$(gcloud compute instances describe orca-jumphost --zone us-east1-b | grep natIP | awk '{print $2}')

gcloud container clusters update orca-cluster-827 \
    --enable-master-authorized-networks \
    --zone us-east1-b \
    --master-authorized-networks $EXT_IP/32    
    

    
