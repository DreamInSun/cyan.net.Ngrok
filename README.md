====================
#cyan-net-Ngrok
====================
## 参考资料 
https://ngrok.com/docs

====================
#部署说明
docker run -d -v $PWD/data:/data -e 'DOMAIN=example.cyan.cc' -p 80:80 -p 443:443 -p 4443:4443 dreaminsun/cyan-net-Ngrok

环境变量
|变量名 	|说明			| 样例
|DOMAIN 	|绑定域名		| example.cyan.cc|
|HTTP_PORT  |HTTP监听端口	| 80			 |
|HTTPS_PORT |HTTPS监听端口	| 443			 |

注意Docker部署时HTTP和HTTPS服务端口必须保持一致。

====================
##客户端安装操作步骤

###配置DNS解析
|*.example.cyan.cc A记录|
|example.cyan.cc A记录|

###下载客户端
sudo wget http://example.cyan.cc:8080/bin/ngrok-linux-amd64
sudo chmod a+x ./ngrok-linux-amd64
sudo mv ngrok-linux-amd64 ngrok

### 编写配置文件
vi ngrok.yml
<code>
server_addr: "ter.ecoho.cn:4443"
trust_host_root_certs: false
</code>

### 运行客户端
./ngrok -subdomain demo -config=./ngrok.yml 8888
看到online则表示运行成功。

### 打开本地监控界面
http://localhost:4040/

=====================
## 高级配置：
tunnels:
  tensorflow:
    proto: http
    addr: 8888
    subdomain: tensorflow 
	
====================