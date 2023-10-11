function createGroup() {
	echo Hello, what Group would you like to create?
	read groupName
	if [ grep $groupName /etc/group -eq 0] # 0 means faulse
	then 
		echo "Group already exists"
	else 
		sudo groupadd $groupName
		cat /etc/group # checking group list
	fi
}

function createUser(){
	echo Hi again. Now you can create a user in a group.
	echo Tell me user_name.
	read userName
	if [ grep $user_name /etc/passwd -eq 0] # 0 means faulse
	then 
		echo "User already exists"
	else
		echo Now, tell me to what group will it  depends?
	        read Name_of_the_group
		sudo useradd -G $Name_of_the_group $userName -m # add user with a home directory to the group
		sudo passwd $userName # initializing password
		cat /etc/passwd # checking user list
	fi
}

createGroup
createUser
