# 15-02-2023

Started following this guide: https://learn.microsoft.com/en-us/devops/deliver/iac-github-actions  
Created an app registration for the project.  
Granted the role 'contributor' for the app registration for the subscription.  
Read about workload identity federation (https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation)  
Created a federated credential to allow GitHub Actions in this project to provision Azure resources.  
Followed the following guide to do so: (https://learn.microsoft.com/en-us/azure/active-directory/develop/workload-identity-federation-create-trust?pivots=identity-wif-apps-methods-azp)  
Configured this credential to be of Entity type: 'branch'  

Added workflows to my GitHub project
1. One for unit testing my Bicep template
2. One for what-if'ing and deploying the template.


# 10-03-2023

As I was not making any progress I decided to make a new branch to start from scratch and focus on making things work rather than making them work inside any of the best practices that exist.