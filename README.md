====================
#cyan-net-Ngrok
====================
## 参考资料 
https://ngrok.com/docs

====================
#部署说明
<code>
```
docker run -d -v /data/ngrok/data:/data -e 'DOMAIN=example.cyan.cc' -p 80:80 -p 443:443 -p 4443:4443 -p 8080:8080 dreaminsun/cyan-net-Ngrok
```
</code>

环境变量
|变量名 	|说明			| 样例 
| ------------- |:-------------:| -----:|
|DOMAIN 	|绑定域名		| example.cyan.cc|
|HTTP_PORT  |HTTP监听端口	| 80			 |
|HTTPS_PORT |HTTPS监听端口	| 443			 |

注意Docker部署时HTTP和HTTPS服务端口必须保持一致。
注意需要Privileged 权限
====================
##客户端安装操作步骤

###配置DNS解析
|子域名 |解析类型| IP地址|
| ------------- |:-------------:| -----:|
|*.example.cyan.cc |A记录| ip|
|example.cyan.cc |A记录| ip|

###下载客户端
<code>
```
sudo wget http://example.cyan.cc:8080/example.cyan.cc/bin/ngrok-linux-amd64
sudo chmod a+x ./ngrok-linux-amd64
sudo mv ngrok-linux-amd64 ngrok
```
</code>

### 编写配置文件
vi ngrok.yml
<code>
```
server_addr: "ter.ecoho.cn:4443"
trust_host_root_certs: false
```
</code>

### 运行客户端
<code>
```
./ngrok -subdomain demo -config=./ngrok.yml 8888
```
</code>
看到online则表示运行成功。

### 打开本地监控界面
http://localhost:4040/

### 公网访问HTTP
http://demo.example.cyan.cc:8080/

=====================
## 高级配置：
```
tunnels:
  tensorflow:
    proto: http
    addr: 8888
    subdomain: tensorflow 
```
	
====================
## Docker Compose
```
cyan-net-Ngork:
  image: daocloud.io/yancy_chen/cyan-net-ngork:master-cc6d842
  privileged: true
  restart: always
  ports:
  - 8080:8080
  - 8443:8443
  - 4040:4040
  - 4443:4443
  volumes:
  - /data/ngork/data:/data
  environment:
  - DOMAIN=ter.ecoho.cn
  - HTTP_PORT=8080
  - HTTPS_PORT=8443
```