#!/bin/bash

	
##############################################################################################
upload()
{
	echo '============================================='
	echo ' Press h to show useage, press Enter to skip' 
	echo '============================================='
	read h
	if [  -n "$h" ];then
	echo	'1.运行脚本后会自动删除之前网口的规则'
	echo	'2.网口输入如格式 0' 
	echo	'3.最大带宽输入格式如 50mbit 此项必须设置'
	echo	'4.带宽限制输入格式如 20mbit 此项必须设置 不得大于最大带宽' 
	echo	'5.延时限制输入格式如 100ms 此项必须设置 如果无限制请设0ms'
	echo	'6.丢包限制输入格式如 1 此项必须设置 如果无限制请设0'
	echo	'7.ip输入格式如 192.168.1.1'
		else
		echo "============="
		echo " Start setup"
		echo "============="
	fi
		rm ./upload	2> /dev/null > /dev/null
	dur=1
while true;do
	#输入要控制的网口
			echo '================================='
			echo ' Which Eth do you want to setup? '
			echo '================================='	
	read eth
	if [ -n "$eth" ];then
	#清除现有网口规则
	tc qdisc del dev eth$eth root    2> /dev/null > /dev/null
		echo 'tc qdisc del dev eth'$eth' root' 2>&1 | tee  -a ./upload
	tc qdisc del dev eth$eth ingress 2> /dev/null > /dev/null
		echo 'tc qdisc del dev eth'$eth' ingress' 2>&1 | tee  -a ./upload
	else
			echo "===================="
			echo " Eth is empty, exit"
			echo "===================="
			exit 1
	fi
	#添加新规则
	tc qdisc add dev eth$eth handle 1: root htb default 100
		echo 'tc qdisc replace dev eth'$eth' handle 1: root htb default 100' 2>&1 | tee -a ./upload
	#设置最大带宽
			echo "==========================="
			echo ' Please input MAX Bandwidth'
			echo "==========================="
	read MB
	tc class add dev eth$eth parent 1:  classid 1:1 htb rate $MB ceil $MB
		echo 'tc class replace dev eth'$eth' parent 1:  classid 1:1 htb rate '$MB' ceil '$MB'' 2>&1 | tee -a ./upload
	tc class add dev eth$eth parent 1:  classid 1:100 htb rate $MB
		echo 'tc class replace dev eth'$eth' parent 1:  classid 1:100 htb rate '$MB'' 2>&1 | tee -a ./upload

	#设置带宽限制
			echo "============================================"
			echo ' Please input limited Bandwidth'
			echo "============================================"
	read LB
	tc class add dev eth$eth parent 1:1 classid 1:1$dur htb rate $LB ceil $LB burst 1500
		echo 'tc class replace dev eth'$eth' parent 1:1 classid 1:1'$dur' htb rate '$LB' ceil '$LB' burst 1500' 2>&1 | tee -a upload

	#设置延时限制
			echo "============================================"
			echo ' Please input limited Delaytime'
			echo "============================================"
	read DT
	tc qdisc add dev eth$eth parent 1:1$dur handle $dur'0': netem delay $DT
		echo 'tc qdisc replace dev eth'$eth' parent 1:1'$dur' handle '$((dur+1))'0'': netem delay '$DT'' 2>&1 | tee -a upload
	#设置丢包限制
			echo "======================================="
			echo ' Please input limited Loss'
			echo "======================================="
	read Loss
	tc qdisc repalce dev eth$eth parent 1:1$dur handle $dur'0': netem delay $DT loss $Loss%
		echo 'tc qdisc replace dev eth'$eth' parent 1:1'$dur' handle '$((dur+1))'0'': netem delay '$DT'' 2>&1 | tee -a upload
	
	#设置目的地址
			echo "======================="
			echo ' Please input Sip'$dur''
			echo "======================="
	read Sip
	iptables -t mangle -A POSTROUTING -o eth$eth -s $Sip -j MARK --set-mark 1$eth
		echo 'iptables -t mangle -A POSTROUTING -o eth'$eth' -s '$Sip' -j MARK --set-mark '1$eth'' 2>&1 | tee -a upload
	iptables -t mangle -A POSTROUTING -o eth$eth -s $Sip -j RETURN
		echo 'iptables -t mangle -A POSTROUTING -o eth'$eth' -s '$Sip' -j RETURN' 2>&1 | tee -a upload
	tc filter add dev eth$eth protocol ip parent 1:0 prio $dur handle 1$eth fw flowid 1:1$dur 
		echo 'tc filter replace dev eth'$eth' protocol ip parent 1:0 prio '$dur' handle '1$eth' fw flowid 1:1'$dur'' 2>&1 | tee -a upload

dur=$((dur+1))
done
}


#####################################################################################################################
download()
{
	echo 'Press h to show useage, press Enter to skip' 
	read h
	if [  -n "$h" ];then
	echo	'1.运行脚本后会自动删除之前网口的规则'
	echo	'2.网口输入如格式 0' 
	echo	'3.最大带宽输入格式如 50mbit 此项必须设置'
	echo	'4.带宽限制输入格式如 20mbit 此项必须设置 不得超过最大带宽' 
	echo	'5.延时限制输入格式如 100ms 此项必须设置 如果无限制请设0ms'
	echo	'6.丢包限制输入格式如 1 此项必须设置 如果无限制请设0'
	echo	'7.ip输入格式如 192.168.1.1'
		else
		echo '============='
		echo " Start setup"
		echo "============="
	fi
	rm ./download	2> /dev/null > /dev/null
	#输入要控制的网口
		echo "================================="
		echo ' Which Eth do you want to setup?'
		echo "================================="	
	read eth
	if [ -n "$eth" ];then
	#清除现有网口规则
	tc qdisc del dev eth$eth root    2> /dev/null > /dev/null
		echo 'tc qdisc del dev eth'$eth' root' 2>&1 | tee  -a ./download
	tc qdisc del dev eth$eth ingress 2> /dev/null > /dev/null
		echo 'tc qdisc del dev eth'$eth' ingress 2' 2>&1 | tee  -a ./download
	else
			echo "===================="
			echo " Eth is empty, exit"
			echo "===================="
			exit
	fi
	#添加新规则
	tc qdisc add dev eth$eth handle 1: root htb default 100
			echo 'tc qdisc replace dev eth'$eth' handle 1: root htb default 100' 2>&1 | tee -a ./download
	#设置最大带宽
		echo "==========================="
		echo ' Please input MAX Bandwidth'
		echo "==========================="	
	read MB
	tc class add dev eth$eth parent 1:  classid 1:1 htb rate $MB ceil $MB
			echo 'tc class replace dev eth'$eth' parent 1:  classid 1:1 htb rate '$MB' ceil '$MB'' 2>&1 | tee -a ./download
	tc class add dev eth$eth parent 1: classid 1:100 htb rate $MB
			echo 'tc class replace dev eth'$eth' parent 1: classid 1:100 htb rate '$MB'' 2>&1 | tee -a ./download	
	dur=1
while true;do
	#设置带宽限制
	echo "============================================"
	echo ' Please input limited Bandwidth'
	echo "============================================"
	read LB
	tc class add dev eth$eth parent 1:1 classid 1:1$dur htb rate $LB ceil $LB burst 1500
			echo 'tc class replace dev eth'$eth' parent 1:1 classid 1:1'$dur' htb rate '$LB' ceil '$LB' burst 1500' 2>&1 | tee -a ./download

	#设置延时限制
		echo "============================================"
		echo ' Please input limited Delaytime'
		echo "============================================"
	read DT
	tc qdisc add dev eth$eth parent 1:1$dur handle $((dur+1))'0': netem delay $DT
			echo 'tc qdisc replace dev eth'$eth' parent 1:1'$dur' handle '$((dur+1))''0': netem delay '$DT'' 2>&1 | tee -a ./download

	#设置丢包限制
		echo "======================================="
		echo ' Please input limited Loss'
		echo "======================================="
	read Loss
		tc qdisc replace dev eth$eth parent 1:1$dur handle $((dur+1))'0': netem delay $DT loss $Loss%
			echo 'tc qdisc replace dev eth'$eth' parent 1:1'$dur' handle '$((dur+1))''0': netem delay '$DT' loss '$Loss'%' 2>&1 | tee -a ./download

	#设置目的地址
		echo '========================'
		echo ' Please input Dip'$dur''
		echo '========================'
	read Dip
	tc filter add dev eth$eth parent 1:  protocol ip prio $dur u32 match ip dst \ $Dip flowid 1:1$dur
			echo 'tc filter replace dev eth'$eth' parent 1:  protocol ip prio '$dur' u32 match ip dst \ '$Dip' flowid 1:1'$dur'' 2>&1 | tee -a ./download
dur=$((dur+1))
done
}


###########################################################################################
replace()
{	
		echo '==============================================='
		echo ' Please select this change for upload/download'
		echo '==============================================='
	read value
if 	[ -z "$value"  ];then
		echo '======================'
		echo ' Invalid value, exit!'
		echo '======================'
	exit
elif [ $value = 'upload' ];then
x=1
while true;do	
	#输入要控制的网口
		echo '================================='
		echo ' Which Eth do you want to setup?'
		echo '================================='	
	read ethx
	if [ -n "$ethx" ];then
			echo "====================="
			echo " Set up on eth$ethx"
			echo "====================="
	else
			echo "===================="
			echo " Eth is empty, exit"
			echo "===================="
		exit 1
	fi
	#选择修改参数
		echo "=============================================="
		echo ' Please input option Delay / Bandwidth / Loss'
		echo "=============================================="
	read option
	if [[ $option = 'Delay' ]];then
		echo "========================"
		echo ' Please input new Delay' #延时
		echo "========================"
		read DTx
	sed -i "/eth$ethx/s/delay .*ms/delay "$DTx"/g" ./upload 
	abc="`grep "tc qdisc replace dev $ethx .* delay" ./upload`"
	$abc
	elif [[ $option = 'Bandwidth'  ]];then
		echo "============================"
		echo ' Please input new Bandwidth' #带宽
		echo "============================"
		read Bandwidthx
	sed -i "/eth$ethx/s/rate .* ceil .* burst 1500/rate "$Bandwidthx" ceil "$Bandwidthx" burst 1500/g" ./upload
	bcd="`grep "tc class replace dev $ethx .* burst 1500" ./upload`"
	$bcd
	elif [[  $option = 'Loss' ]];then
		echo "======================="
		echo ' Please input new loss' #丢包
		echo "======================="
		read Lossx
	sed -i "/eth$ethx/s/loss .*/loss "$Lossx"%/g" ./upload
	cde="`grep "tc qdisc replace dev $ethx parent .* loss" ./upload`"
	$cde
	fi
x=$((x+1))
done
##########################################################################################
elif [ $value = 'download' ];then
	y=1
while true;do	
	#输入要控制的网口
		echo '================================='
		echo ' Which IP do you want to setup?'
		echo '================================='	
	read ip
	if [ -n "$ip" ];then
		echo '====================='
		echo ' Set up on '$ip''
		echo '====================='
	lineip=$(grep -n "$ip" download | cut -d ":" -f 1)
	else
		echo '===================='
		echo " IP is empty, exit"
		echo '===================='
		exit 1
	fi
	#选择修改参数
		echo '=============================================='
		echo ' Please input option Delay / Bandwidth / Loss'
		echo '=============================================='
	read optiony
	if [[ $optiony = 'Delay' ]];then
		echo '========================'
		echo ' Please input new Delay' #延时
		echo '========================'
		read DTy
	ld=$(expr $lineip - 1)
	sed -i "$ld"s"/delay .* loss/delay $DTy loss/g" download
	abc=$(sed -n $ld'p' download)	
	$abc
	elif [[  $optiony = 'Bandwidth'  ]];then
		echo "============================"
		echo ' Please input new Bandwidth' #带宽
		echo "============================"
		read BWy
	lb=$(expr $lineip - 3)
	sed -i "$lb"s"/rate .* ceil .* burst/rate $BWy ceil $BWy burst/g" download
	bcd=$(sed -n $lb'p' download)
	$bcd
	elif [[  $optiony = 'Loss' ]];then
		echo "======================="
		echo ' Please input new loss' #丢包
		echo "======================="
		read Lossy
	ls=$(expr $lineip - 1)
	sed -i "$ls"s"/loss .*/loss $Lossy"%"/g" download
	cde=$(sed -n $ls'p' download)
	$cde
	fi
y=$((y+1))
done
else 
		echo '======================'
		echo ' Invalid value, exit!'
		echo '======================'
fi
}

###########################################################################################

echo "================================================================="
echo "          Please select test method: download / upload."
echo " If you already have TC option, just want to modify, use replace"
echo "================================================================="
	read method
{
if [[ $method = 'upload' ]];then
	$method
   elif [[ $method = 'download' ]];then
	$method
   elif [[ $method = 'replace' ]];then
	$method
   else
	echo 'Please input available value: download / upload / replace'
exit 1
fi
}

main $@ 2>&1 | tee ./camera.txt
cd ..
