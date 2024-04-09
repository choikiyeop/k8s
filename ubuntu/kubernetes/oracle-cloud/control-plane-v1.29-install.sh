# 기본 오라클 클라우드 인스턴스 설정
sudo iptables-save > ~/iptables-rules

grep -v "DROP" iptables-rules > tmpfile && mv tmpfile iptables-rules-mod
grep -v "REJECT" iptables-rules-mod > tmpfile && mv tmpfile iptables-rules-mod

sudo iptables-restore < ~/iptables-rules-mod

sudo iptables -L

sudo netfilter-persistent save
sudo systemctl restart iptables

sudo ufw disable

# /etc/hosts에서 아래 추가(프라이빗 IP, 퍼블릭 IP)
# 10.0.14.71		x.x.x.x

# docker 설치

# 기본 설정

# kubeadm install

sudo iptables-save > ~/iptables-rules
grep -v "DROP" iptables-rules > tmpfile && mv tmpfile iptables-rules-mod
grep -v "REJECT" iptables-rules-mod > tmpfile && mv tmpfile iptables-rules-mod
sudo iptables-restore < ~/iptables-rules-mod
sudo iptables -L
sudo netfilter-persistent save
sudo systemctl restart iptables
sudo ufw disable
vi /etc/hosts # 호스트 추가 <퍼블릭ip> <프라이빗 ip>
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
sudo swapoff -a && sudo sed -i '/swap/s/^/#/' /etc/fstab
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
containerd config default | sudo tee /etc/containerd/config.toml
vi /etc/containerd/config.toml    # systemCgroup = true 변경
systemctl restart containerd
kubeadm join 10.0.14.71:6443 --token yoyw1l.b3gbh8z5l1vd3rl4         --discovery-token-ca-cert-hash sha256:0fa562d1b3ffff704958a7ca22196cccdb408aaa586a261258226e5eb76e38bf
