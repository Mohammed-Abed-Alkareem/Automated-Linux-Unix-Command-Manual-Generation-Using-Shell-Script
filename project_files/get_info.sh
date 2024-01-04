
Commands=("wc"  "man" "grep" "ls" "pwd" "date" "who" "head" "tr" "paste" "tail" "sed" "printf"  "touch" "pico" "mkdir" "cd" "cp" "rm" "mv" "cat") #array of the commands
directory="generated_manuals"


# Function to format multiline text
format_multiline() {
	local text="$1"
	local width=100  
	local indentation="                   | "  # Spaces for proper indentation

	# Print the header
	printf "%-18s | %s\n" "Description" ""

	# Loop through the text
	while [ -n "$text" ]; do
		# Extract a substring of the specified width
		line="${text:0:$width}"
		text="${text:$width}" # Remove the extracted portion from the original text

    		# Print the line with proper indentation
    		if [ -n "$line" ]; then
      			printf "%-18s | %s\n" "" "$line"
    		fi
  	done
}


get_command_description() {
	local command_name="$1" #accepts the command name as parameter
	local description

	description=$(man "$command_name" 2>/dev/null | sed -n '/^DESCRIPTION/,$p' | sed '1d;/^$/q' |  tr -d '\n' | sed 's/^[ \t]*//' )
	#first sed removes every thing before Description
	#second sed removes every thing after reaching empty line
	#remove each \n
	#remove initial spaces

	if [ -z "$description" ] #if the description is still empty
	then 
		description=$("$command_name" --help | sed -n '2p')
   	#take the second line of the help page
  	fi

	if [ -z "$description" ] #if the description is still empty
  	then 
    	description="there is no description for $command_name"    
  	fi

	echo "$description" #return the discription
}

get_command_version() {
	local command_name="$1" #accepts the command name as parameter
  	local version

  	version=$("$command_name" --version 2>/dev/null | head -n 1 | cut -d' ' -f2-)
  	#FROM --version take the first line then split it by the space and take the second part 

  	if [ -z "$version" ] #if the version is still empty
  	then
    		version=$("$command_name" -v 2>/dev/null | head -n 1 | cut -d' ' -f2-)
    		#check the -v and do the same
  	fi

  	if [ -z "$version" ] #if the version is still empty
  	then 
    		version=$(man "$command_name" 2>/dev/null | sed -n '/^Version/,$p' | head -n 1 | cut -d' ' -f2-)
    		#check the version if it is written in the manual 
    		#delete every thing befor Version
    		#take the first line then split it by the space and take the second part
  	fi

  	if [ -z "$version" ] #if the version is still empty
   	then
    		version="As the BASH version: "
   		version+=$(bash --version | cut -d' ' -f4-5 | head -n 1)
    		#then the version of the command is same as the bash
  	fi

 	echo -e "$version" #return the version
}

get_command_example() {
    command=$1

    case $command in
        "wc")
            echo "wc -l filename.txt"
            ;;
        "man")
            echo "man ls"
            ;;
        "grep")
            echo "grep 'pattern' filename.txt"
            ;;
        "ls")
            echo "ls -l"
            ;;
        "pwd")
            echo "pwd"
            ;;
        "date")
            echo "date '+%Y-%m-%d %H:%M:%S'"
            ;;
        "who")
            echo "who"
            ;;
        "head")
            echo "head -n 5 filename.txt"
            ;;
        "tr")
            echo "tr '[:lower:]' '[:upper:]' < filename.txt"
            ;;
        "paste")
            echo "paste file1.txt file2.txt"
            ;;
        "tail")
            echo "tail -n 10 filename.txt"
            ;;
        "sed")
            echo "sed 's/pattern/replacement/' filename.txt"
            ;;
        "printf")
            echo "printf 'Hello, %s!\n' 'User'"
            ;;
        "touch")
            echo "touch newfile.txt"
            ;;
        "pico")
            echo "pico filename.txt"
            ;;
        "mkdir")
            echo "mkdir new_directory"
            ;;
        "cd")
            echo "cd /path/to/directory"
            ;;
        "cp")
            echo "cp file1.txt file2.txt"
            ;;
        "rm")
            echo "rm filename.txt"
            ;;
        "mv")
            echo "mv oldfile.txt newfile.txt"
            ;;
        "cat")
            echo "cat filename.txt"
            ;;
        *)
            echo -e "No example available for $command"
            ;;
    esac
}


get_related_commands() {
	local command_name="$1" #accepts the command name as parameter
 	local related_commands

  	related_commands=$(man -k "$command_name" | cut -d" " -f1 | shuf -n 5 | paste -sd "\t")
  	#man -k return related commands taking only the name then mak the delemeter is \t instead of \n

  	echo "$related_commands"
}

print_line() {
    printf '%-120s\n' | tr ' ' '_' #print _*120
}


generate_manual() {
    local command=$1

    description=$(get_command_description "$command")
    version=$(get_command_version "$command")
    related_commands=$(get_related_commands "$command")
    example=$(get_command_example "$command")

    # Print the table with formatted columns
    format_multiline "$description" >> generated_manuals/$command.txt
    print_line >> generated_manuals/$command.txt

    printf "%-18s | %s\n" "Version" "$version" >> generated_manuals/$command.txt
    print_line >> generated_manuals/$command.txt

    printf "%-18s | %s\n" "Example" "$example" >> generated_manuals/$command.txt
    print_line >> generated_manuals/$command.txt

    printf "%-18s | %s\n" "Related Commands" "$related_commands" >> generated_manuals/$command.txt
    print_line >> generated_manuals/$command.txt

    printf "%-18s |\n" "Notes" >> generated_manuals/$command.txt
    print_line >> generated_manuals/$command.txt

    echo -e "-) Manual For \\033[1m$command\\033[0m has been saved in generated_manuals/$command.txt"
}

generate_all_manuals() {
    for command in "${Commands[@]}"; do
        generate_manual "$command"
    done

    echo
    echo -e "\\033[1mMANUALS GENERATED SUCCESSFULLY ^_^\\033[0m"
}



recommend_commands() {
     entered_command=$1

    case $entered_command in
      "ls")
            echo "==> Recommended commands: cd, cp, mv"
            ;;
        "grep")
            echo "==> Recommended commands: sed, awk, cut"
            ;;
        "mkdir")
            echo "==> Recommended commands: ls, cd"
            ;;
        "touch")
            echo "==> Recommended commands: ls, pico, chmod"
            ;;
        "cat")
            echo "==> Recommended commands: grep, sed, tr"
            ;;
        "cd")
            echo "==> Recommended commands: touch, pwd, mkdir"
            ;;
        "wc")
            echo "==> Recommended commands: awk, sed, sort"
            ;;
        "man")
            echo "==> Recommended commands: info, apropos"
            ;;
        "pwd")
            echo "==> Recommended commands: cd, ls, echo"
            ;;
        "date")
            echo "==> Recommended commands: cal, timedatectl"
            ;;
        "who")
            echo "==> Recommended commands: w, finger, last"
            ;;
        "head")
            echo "==> Recommended commands: tail, sed, awk"
            ;;
        "tr")
            echo "==> Recommended commands: sed, awk, cut"
            ;;
        "paste")
            echo "==> Recommended commands: join, sort, awk"
            ;;
        "tail")
            echo "==> Recommended commands: head, sed, awk"
            ;;
        "sed")
            echo "==> Recommended commands: awk, grep, tr"
            ;;
        "printf")
            echo "==> Recommended commands: echo, awk, printf"
            ;;
        "pico")
            echo "==> Recommended commands: nano, vim, emacs"
            ;;
        "cp")
            echo "==> Recommended commands: mv, rsync, scp"
            ;;
        "rm")
            echo "==> Recommended commands: mv, find, rmdir"
            ;;
        "mv")
            echo "==> Recommended commands: cp, rsync, scp"
            ;;
        *)
            echo "==> No specific recommendations for '$entered_command'"
            ;;
    esac
}
echo
echo -e "\\033[1 ~~~ WELCOME TO MY PROJECT ^_^ ~~~\\033[0m"


while true
do
echo #main menu
echo "1. Generate Manuals"
echo "2. Verify Manuals"
echo "3. Show Manuals "
echo "4. Serech for a command"
echo "5. EXIT"
echo
read -p "Enter your choice: "  choice #scanf &choice
echo

case "$choice" in
1)
	# Check if the directory exists
	if [ -d "$directory" ]; then
    		# If it exists, delete it and its contents
    		rm -rf "$directory"
	fi

	# Create the directory
	mkdir "$directory"

	generate_all_manuals
;;

2)

	# Check if the directory exists
	if [ ! -d "$directory" ]
	then
	    # If it not exists,
	    echo "You Need To Generate The Manuals First... "
      	    read -p "Do you want to generate the manuals? answer with (yes/no) " y_n
	    until [ $y_n = 'yes' -o $y_n = 'no' ]
	    do
		    read -p "You Have to answer with (yes/no) " y_n
	    done
	    
	    if [ $y_n = 'no' ]
	    then
	    	continue
	    else
	    
	    	# Create the directory
		mkdir "$directory"
		generate_all_manuals
	    
	    fi

	fi

	for command in "${Commands[@]}"
	do

		if [ !  -e "$directory/$command.txt" ]
		then
			echo -e "the manual for \\033[1m$command\\033[0m does not exists"
			read -p "Do you want to generate the manual for $command? answer with (yes/no) " y_n
	   		until [ $y_n = 'yes' -o $y_n = 'no' ]
	    		do
		    		read -p "You Have to answer with (yes/no) " y_n
	    		done
	    
	    		if [ $y_n = 'no' ]
	    		then
	    			continue 
	    		else
				generate_manual "$command"
	    		fi 
		fi

		description_extracted=$(cat $directory/$command.txt | awk '/Description/,/_/' | grep -v "Description" | sed 's/[^[:alnum:]]//g' |  tr -d '\n' )
		#open the generated manual
		#get from the Description to the '_'
		#delete "Description"
		#delete any special character !(letter or number)
		#delete any new line
		description=$(get_command_description "$command" | sed 's/[^[:alnum:]]//g' |  tr -d '\n')
		#get the description as geted in previous
		##delete any special character !(letter or number)
		#delete any new line

		version_extracted=$(cat $directory/$command.txt | awk -F'|' '/Version/ {print $2}' |  sed 's/[^[:alnum:]]//g' |  tr -d '\n')
		#open the generated manual
		#get from the | after version to the end of the line
		##delete any special character !(letter or number)
		#delete any new line
		version=$(get_command_version "$command"  | sed 's/[^[:alnum:]]//g' |  tr -d '\n')
		#get the description as geted in previous
		##delete any special character !(letter or number)
		#delete any new line

		if [ "$description" = "$description_extracted" -a "$version" = "$version_extracted"  ] #if there is no changes in the description or in the version then verified
		then
			echo -e "-)\\033[1m$command\\033[0m verified successfully"
		else
			echo -e "*)there is an error with \\033[1m$command\\033[0m manual"
			
			read -p "Do you want to regenerate the manual for $command? answer with (yes/no) " y_n
	   		until [ $y_n = 'yes' -o $y_n = 'no' ]
	    		do
		    		read -p "You Have to answer with (yes/no) " y_n
	    		done
	    
	    		if [ $y_n = 'no' ]
	    		then
	    			continue 
	    		else
	    			rm $directory/$command.txt
				generate_manual "$command"
	    		fi
			
		fi

	done

;;

3)
	# Check if the directory exists
	if [ ! -d "$directory" ]
	then
	    # If it not exists,
	    echo "You Need To Generate The Manuals First... "
      	    read -p "Do you want to generate the manuals? answer with (yes/no) " y_n
	    until [ $y_n = 'yes' -o $y_n = 'no' ]
	    do
		    read -p "You Have to answer with (yes/no) " y_n
	    done
	    
	    if [ $y_n = 'no' ]
	    then
	    	continue
	    else
	    
	    	# Create the directory
		mkdir "$directory"
		generate_all_manuals
	    
	    fi

	fi


	echo "    a) Sort by lexicographical order "
        echo "    b) Sort by date"
        echo
        read -p "    Enter your choice: "  choice
        echo
        case "$choice" in

        a)
                ls $directory
        ;;

        b)
               ls --sort time  $directory
        ;;

	*)
                echo "    Invalid Choice *_*"

        esac

;;

4)
	# Check if the directory exists
	if [ ! -d "$directory" ]
	then
	    # If it not exists,
	    echo "You Need To Generate The Manuals First... "
      	    read -p "Do you want to generate the manuals? answer with (yes/no) " y_n
	    until [ $y_n = 'yes' -o $y_n = 'no' ]
	    do
		    read -p "You Have to answer with (yes/no) " y_n
	    done
	    
	    if [ $y_n = 'no' ]
	    then
	    	continue
	    else
	    
	    	# Create the directory
		mkdir "$directory"
		generate_all_manuals
	    
	    fi

	fi

	read -p "Enter the command name: "  command

	if ! compgen -c | grep -q "^$command$"; then
    		echo -e "\\033[1m$command\\033[0m is not a valid command."
		continue
 	else
		if [ !  -e "$directory/$command.txt" ]
     		then
           		echo -e "the manual for \\033[1m$command\\033[0m does not exists"
	   		continue
		fi
	fi


	echo
	echo "    a) Show All Info "
	echo "    b) Show Description"
	echo "    c) Show Version"
	echo "    d) Show Example"
	echo "    e) Show Related Commands"
	echo
	read -p "    Enter your choice: "  choice
	echo
	case "$choice" in
	
	a)
		cat $directory/$command.txt
		echo
		recommend_commands "$command"
	;;

	b)
		cat $directory/$command.txt | awk '/Description/,/_/'
		#open the generated manual
		#get from the Description to the '_'
		echo
		recommend_commands "$command"
	;;
	
	c)
		cat $directory/$command.txt | awk '/Version/,/_/'
		#open the generated manual
		#get from the Version to the '_'
		echo
		recommend_commands "$command"
	;;

	d)
		cat $directory/$command.txt | awk '/Example/,/_/'
		#open the generated manual
		#get from the Example to the '_'
		echo
		recommend_commands "$command"
	;;

	e)
		cat $directory/$command.txt | awk '/Related Commands/,/_/'
		#open the generated manual
		#get from the Related Commands to the '_'
		echo
		recommend_commands "$command"
	;;

	*)
		echo "    Invalid Choice *_*"

	esac

;;

5)
	echo
	echo -e "\\033[1 ~~~ THANKS FOR USING MY PROJECT ^_^ ~~~\\033[0m"
	break
;;

*)

	echo "Invalid Choice"

esac
done
