#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Git Helper Script${NC}\n"

# Function to show menu
show_menu() {
    echo -e "${YELLOW}Available commands:${NC}"
    echo "1. Status check"
    echo "2. Add all changes"
    echo "3. Add specific file"
    echo "4. Commit changes"
    echo "5. Push to remote"
    echo "6. Pull from remote"
    echo "7. Create new branch"
    echo "8. Switch branch"
    echo "9. Merge branch"
    echo "10. View commit history"
    echo "11. Discard changes"
    echo "12. Exit"
    echo ""
}

# Main loop
while true; do
    show_menu
    read -p "Enter your choice (1-12): " choice
    echo ""

    case $choice in
        1)
            echo -e "${GREEN}Checking status...${NC}"
            git status
            ;;
        2)
            echo -e "${GREEN}Adding all changes...${NC}"
            git add .
            git status
            ;;
        3)
            read -p "Enter file path: " file
            echo -e "${GREEN}Adding $file...${NC}"
            git add "$file"
            git status
            ;;
        4)
            read -p "Enter commit message: " message
            echo -e "${GREEN}Committing changes...${NC}"
            git commit -m "$message"
            ;;
        5)
            read -p "Enter branch name [main]: " branch
            branch=${branch:-main}
            echo -e "${GREEN}Pushing to $branch...${NC}"
            git push origin "$branch"
            ;;
        6)
            read -p "Enter branch name [main]: " branch
            branch=${branch:-main}
            echo -e "${GREEN}Pulling from $branch...${NC}"
            git pull origin "$branch"
            ;;
        7)
            read -p "Enter new branch name: " branch
            echo -e "${GREEN}Creating and switching to new branch $branch...${NC}"
            git checkout -b "$branch"
            ;;
        8)
            read -p "Enter branch name: " branch
            echo -e "${GREEN}Switching to branch $branch...${NC}"
            git checkout "$branch"
            ;;
        9)
            read -p "Enter branch to merge: " branch
            echo -e "${GREEN}Merging branch $branch...${NC}"
            git merge "$branch"
            ;;
        10)
            echo -e "${GREEN}Showing commit history...${NC}"
            git log --oneline --graph --decorate -n 10
            ;;
        11)
            echo -e "${RED}Warning: This will discard all local changes!${NC}"
            read -p "Are you sure? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                git reset --hard
                echo "Changes discarded"
            fi
            ;;
        12)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
    clear
done 