#!/bin/zsh
wget 'https://raw.githubusercontent.com/trickest/resolvers/main/resolvers-extended.txt'
cat resolvers-extended.txt | grep 'AU' | cut -d " " -f1 >> RESOLVERS_AU.txt

while read line; 
	do 
		echo $line'#'$line >> resolvers_au_tagged.txt;
done < RESOLVERS_AU.txt

./test.sh >> output.txt &
# cat output.txt | sort -k 22 >> sorted.txt
# cat sorted.txt | cut -d " " -f1 >> resolvers_syd.txt
