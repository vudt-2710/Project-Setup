# Bypass Basic Authentication

## IP Whitelist

> This will allow any connection coming from any of the below IPs to access the domain without Basic Authen prompt from the browser, with ```1``` will not be asked but ```0``` will

```
geo $allow {
	default 0;
	14.176.232.181/32 1;
	118.69.176.252/32 1;
	42.116.19.204/32 1;
	172.16.0.0/16 1;
	1.55.242.188/32 1;
	42.112.114.236/32 1;
	116.97.243.74/32 1;
	103.37.29.230/32 1;
	14.160.25.214/32 1;
	42.116.7.14/32 1;
	192.168.0.0/16 1;
	10.0.0.0/8 1;
	113.190.253.26/32 1;
	14.161.42.46/32 1;
	118.69.186.112/32 1;
	172.17.0.0/22 1;
	10.10.1.0/24 1;	
}
```

> And this is a condition to check whether the specific IP is allowed to visit without Basic Authen. Replace the ```auth_basic``` and ```auth_basic_user_file``` with these 2 lines inside the server block

```
auth_basic $auth;
auth_basic_user_file /etc/nginx/authen/.htpasswd-{{ item.servername }};
```