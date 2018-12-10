checkFile() {
while read line; do
	if [[ $line = $1 ]]; then 
		read line
		echo "$line"
	else  
		echo  
	fi
	
done < output.txt
}


testLine(){
if [[ ! $1 =~ '#' ]]; then
		line=$(echo $1|tr -d '\n\r')
		out=$(curl -s -w 'http_code=%{http_code}' $line|tr -d '\n\r')
		out=$(echo $out|grep 'http_code=200')
		out=$(echo $out|tr -d '\n\r')
		result=$(checkFile $line)
		if [[ $out == "" ]]; then
			echo $line "FAILED"
		elif [ -n "$result" ]; then
			out=$(echo $out|md5sum)
			if [[ $result != *"$out"* ]]; then
				echo $line
				echo $line >> output2.txt
				echo $out >> output2.txt
			fi
		else
			out=$(echo $out|md5sum)
			echo $line "INIT"
			echo $line >> output2.txt
			echo $out >> output2.txt
		fi
	fi	
}
while read line; do
	testLine $line &
done < $1
testLine $line &
wait
echo "done"
if [ -e "output2.txt" ]; then
	cp output2.txt output.txt
	rm output2.txt
fi
