from diagrams import Diagram, Cluster
from diagrams.aws.compute import EC2
from diagrams.onprem.vcs import Github
from diagrams.onprem.container import Docker
from diagrams.programming.language import Bash
from diagrams.generic.network import Firewall
from diagrams.onprem.client import Users

with Diagram("CI/CD Deployment Pipeline - GitHub to EC2", show=True, direction="LR"):

    users = Users("Web Users")

    with Cluster("GitHub"):
        repo = Github("Repo (main branch)")
        webhook = Bash("Webhook Event")

    with Cluster("AWS EC2"):
        firewall = Firewall("SG Rules (4200/9000)")
        ec2 = EC2("Ubuntu 24.04")
        docker = Docker("Docker Runtime")
        redeploy = Bash("redeploy.sh")

        webhook >> firewall >> ec2
        ec2 >> redeploy >> docker

    repo >> webhook
    docker >> users
