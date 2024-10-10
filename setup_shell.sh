#!/bin/bash

create_user() {
    read -p "Enter the username to create: " new_user
    sudo useradd -m -s /bin/bash "$new_user"
    if [ $? -eq 0 ]; then
        echo "User $new_user created successfully."
        sudo passwd "$new_user"
        setup_default_tools "$new_user"  # Apply predefined template after user creation
    else
        echo "Failed to create user $new_user."
    fi
}

list_users() {
    cat /etc/passwd
}

remove_user() {
    read -p "Enter the username to remove: " del_user
    sudo userdel -r "$del_user"
    if [ $? -eq 0 ]; then
        echo "User $del_user removed successfully."
    else
        echo "Failed to remove user $del_user."
    fi
}

configure_user() {
    echo "Available users on the system:"
    list_users

    read -p "Enter the username to configure: " selected_user
    user_home="/home/$selected_user"

    if id "$selected_user" &>/dev/null; then
        if [ -d "$user_home" ]; then
            setup_default_tools "$selected_user"  # Apply predefined template for the selected user
            echo "Shell environment for $selected_user has been successfully configured."
        else
            echo "Home directory for user $selected_user does not exist!"
        fi
    else
        echo "User $selected_user does not exist!"
    fi
}

setup_default_tools() {
    user_home="/home/$1"

    # Set up .bashrc with custom configurations
    cat <<EOL > "$user_home/.bashrc"
# Custom Environment Setup for $1
export PATH=\$PATH:/usr/local/my_custom_bin
export EDITOR=nano
export MY_PROJECT_DIR=\$HOME/projects
   
# Custom aliases for $1
alias ll='ls -alF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias cls='clear'
alias c='clear'
alias h='history'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -p'

# Custom prompt
export PS1='\u@\h:\w\$ '
EOL

   
    chown "$1:$1" "$user_home/.bashrc"
    chmod 644 "$user_home/.bashrc"

  
    mkdir -p "$user_home/projects"
    chown "$1:$1" "$user_home/projects"

    echo "Default tools and configurations set for user $1."
}

# Check if script is run by the 'aniket' user
if [ "$USER" != "lap" ]; then
    echo "This script must be run as the aniket user. Please check!!."
    echo $USER
    exit 1
fi

# Menu options
echo "1. Create a new user"
echo "2. List all users"
echo "3. Remove a user"
echo "4. Configure environment for a selected user"
read -p "Choose an option: " option

case $option in
    1)
        create_user
        ;;
    2)
        list_users
        ;;
    3)
        remove_user
        ;;
    4)
        configure_user
        ;;
    *)
        echo "Invalid option selected. Exiting."
        exit 1
        ;;
esac
