# HelloID-Conn-Prov-Source-Skyward-Qmlativ-Students

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |
<br />
<p align="center"> 
  <img src="https://www.tools4ever.nl/connector-logos/skywardqmlativ-logo.png">
</p>
<br />

HelloID Provisioning Source Connector for Skyward Qmlativ Custom API

## Table of Contents
- [Available Data](#available-data)
- [Setting up the API Access](#setting-up-the-api-access)
  - [Navigating to the integration list](#navigating-to-the-integration-list)
  - [Explanation of the integration list](#explanation-of-the-integration-list)
  - [Starting integration access setup](#starting-integration-access-setup)
  - [Add Integration Access Workflow](#add-integration-access-workflow)
  - [Additional Configuration](#additional-configuration)
      - [OneRoster Configuration](#oneroster-configuration)
      - [Adding a OneRoster Configuration](#adding-a-oneroster-configuration)
      - [Custom API Configuration](#custom-api-configuration)
  - [Saving Integration Access](#saving-integration-access)
  - [Completing the Add Integration Access Workflow](#completing-the-add-integration-access-workflow)
  - [Starting the generate secret workflow](#starting-the-generate-secret-workflow)
  - [Completing the workflow](#completing-the-workflow)
- [Configure HelloID](#configure-helloid)
- [HelloID docs](#helloid-docs)


## Available Data
Access to data is controlled by Skyward approval. Please refer to the [Intergation Access XML](/IntegrationAccess.xml) for specifics to which table and fields are available. Also, it refers to what CRUD action are available as well.

## Setting up the API Access

### Navigating to the integration list
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/a7d41a3d-4d01-459d-89b4-86fa461e05af)

Every Integration will have a record available within Qmlativ, which you can view by navigating to the Integration List screen. To locate this list of Integrations:
1.	Open the Main menu within Qmlativ.
2.	Select the Administrative Access portal.
3.	Choose the API module.
4.	Select the Integration feature.

### Explanation of the integration list
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/476cf836-4202-471c-a73b-b14ea22be6b8)

On the Integration List screen, you will see a list of Integrations. By default, these Integrations are sorted by the Vendor Name (1) and then by the Product Name (2), which should make the Integrations easy to locate within the list.
The Description (3) column provides an explanation of the purpose of the Integration, and should help you, as the district, determine if the Integration will be useful for your district.
The Status (4) column shows the current state of the Integration, such as whether it is Available or if it has been Discontinued.  A Discontinued Integration that appears for you is one that has either recently been discontinued from use or one that you have used in the past which is no longer available.

The Has Development Permissions (5) column provides an indication of whether the Integration is allowed to access your environment while it is in development by the vendor.  In a Live environment, this should display as unchecked, however, in a Training environment, you may see this item checked if you are working with a vendor for development purposes.

The Can Generate Secret (6) column provides an indication as to whether you, as the district, are allowed to generate the secret that is used for the Integration’s authentication. If this box is checked, the vendor has enabled the option and expects that you will provide the secret to them using a secure method so they may authenticate with Qmlativ (see the Vendor Integration Setup below).  If this option is unchecked, the vendor has chosen to manage secret authentication themselves using Skyward’s secure Partner Portal.

### Starting integration access setup
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/4420329a-9d57-4a51-9d52-9fe22dc9ef89)

From the Integration List screen, click the Open (1) button on the Integration for which you want to grant access, this will take you to the Integration Details screen.

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/e61b79ab-b16b-4718-8ae7-8994ba3cf620)

On the Integration Details screen, select the Integration Accesses (1) tab, which will display a list of Integration Access records available for this Integration (note that no records will display when you first view this screen). Click the Add Integration Access (2) button to begin the Add Integration Access workflow.

### Add Integration Access Workflow
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/5e8f663c-411f-4a7d-8581-e9ba373dbeda)

In the Add Integration Access Workflow, you will need to set the following fields on the Integration:

1.	Name (required): This is a “friendly” name that allows the district to easily identify the Integration Access and allow the district to differentiate it from another Integration Access for the same Integration. It is often useful to name this with the Integration’s name plus the year or purpose of the access being granted, such as “{Integration} 2023” or “{Integration} Vendor Testing”. Note: this name does not affect the access credentials used to connect to the API(s).
2.	Description (optional): This description allows you to provide more details on the purpose of the Integration Access if the Name field does not provide enough context.
3.	Integration (required): When starting the Add Integration Access Workflow from the Integration Details screen, the Integration will be automatically set to the Integration which was selected at the start of the workflow. When starting the workflow from other locations, such as the Integration Access List screen, this field will need to be filled in with the name of the Integration to which you are granting access.
4.	Key (required): This key functions as the Client Key or “username” by the third-party vendor when authenticating with Qmlativ’s APIs. This value must be unique, and the third-party vendor may require that the value be configured to a specific value (see Vendor Integration Setup below).
5.	Authentication Type (required): The indicates the type(s) of authentication are available to the third-party vendor when authenticating with Qmlativ.  Skyward recommends setting this option to “Any”, as this will allow the vendor to access the Integration using their preferred authentication type, and it will not require any changes to be made if other authentication types are added or removed in the future.
a.	NOTE: “Basic” is currently offered as an option for the authentication type, but this option will be removed at the start of the 2024-25 school year and is not recommended.
6.	Is Active (required): Indicates whether the Integration Access is active.
7.	Effective Date (required): The date from which the Integration Access becomes available to the third-party vendor.
8.	Expiration Date (optional): The date after which the Integration Access is no longer available to the third-party vendor.
•	NOTE: an Integration Access is only truly active if the “Is Active” checkbox is checked and if the current date falls after the Effective Date and before the Expiration Date. If no Expiration Date is provided, then the Integration Access will not expire, and will remain active as long as the “Is Active” box is checked, and the current date is after the Effective Date.

### Additional Configuration
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/a04620e8-e28c-4792-9126-1f036ff9b743)

Beyond the above settings on the Add Integration Access workflow, there may be additional configuration necessary depending on the APIs used by the third-party Integration. If any additional configuration is necessary, a Configuration section will appear below the Expiration Date.

#### OneRoster Configuration
Description: the OneRoster API allows third-party Integrations access to rostering information, such as name and certain demographic information, as well as information related to scheduling and grading.

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/92e47b65-5598-4e41-b159-55b7b5137bda)

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/830d4ac9-37b1-4f84-a2cd-a67bfcc3e0c1)

Click the arrow (1) next to the OneRoster Configuration selector, this will display a list of available OneRoster Configurations. Click the Select (2) button next to the appropriate configuration, if one is available, or click the Add One Roster Configuration (3) button to add a new configuration.

#### Adding a OneRoster Configuration
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/29b2ea02-e3d6-4ee2-b195-f105355644e0)

On the Add One Roster Configuration workflow, you will need to fill in several fields:
1.	One Roster Vendor (required): this is the name of the vendor as configured for the purposes of OneRoster communications. Click the arrow next to the selector to select the name of an existing vendor or click the Add One Roster Vendor button within the list to add a new vendor.  The workflow for adding a new vendor contains a single field, which is the vendor’s name.
2.	Code (required): this is a generic code that can be used to identify the OneRoster configuration.
3.	Description (optional): this description allows you to provide additional context for the configuration, such as notes about a specific vendor or Integration.
4.	District (required): select your district from the list.
5.	Allow Grade Pass Back (optional): this option allows the third-party vendor’s Integration to write grade information back into Qmlativ. 
a.	NOTE: Selecting this option requires additional licensing from Skyward for the grade pass back to function. If you are uncertain if your district has the appropriate licensing, you may look in Administrative Access > System > System Profile, then select the Products Owned tab and search for the “QM OneRoster API with writeback” product. If you do not have this products owned record available and would like to use the grade pass back option, please contact your Sales Representative.

#### Custom API Configuration
Description: the Custom API allows third-party Integrations to potentially access any field within Qmlativ.  However, the fields to which they have access are limited based on review by Skyward.  

To see a list of the fields to which an Integration has access, you can navigate to Administration Access > API > Integration, open the specific Integration from the list, then click on the Integration APIs tab. On the Integration APIs tab, select the Custom API from the list, and a list of Integration Objects and Integration Fields will be displayed in the lists below.

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/2c1b3a27-0a06-406c-9b90-60d4a17f90b4)

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/59f07ae6-fcfd-4699-acd1-6d735062452e)

Click the magnifying glass (1) next to the Custom API Entities selector, this will display a list of available Entities.  Check the boxes (2) next to the Entities that you want the Integration to access when using the Custom API.

NOTE: in a single-district configuration, it is common to select all Entities from the list, so that the Integration may access information from the entire district.  However, there may be situations where limiting access to specific Entities may be required, such as for certain licenses (for instance, if a high school uses an Integration, but the elementary school does not).

In a multi-district configuration, it is common to create a separate Integration Access for each district that is utilizing the Integration, and then limiting the Integration Access to the entities within that specific district.  This will allow more granular control on a district-by-district basis.

### Saving Integration Access
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/3d548330-b3f5-4824-9774-611b40e911e6)

After filling in the main section of the Add Integration Access workflow (1) and any additional configuration (2), click the Save button to complete the first step of the workflow.

### Completing the Add Integration Access Workflow
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/d4d08b4d-7689-4e64-b141-4e48047f1ed4)

After saving the workflow, you will be presented with a window indicating that the process was completed successfully, which means the Integration Access record was created.  

If the Integration allows you to generate a secret, you will have a Generate Secret (1) button displayed at the top along with the Close (2) button.  If you are not allowed to generate the secret, you will only see the Close button.  Click the Generate Secret (1) button to generate a secret for this Integration Access.

NOTE: the Generate Secret button will generally only be available to you if the third-party vendor offers a form of self-setup for the Integration or if the Integration is being used from a physical device that requires setup at the district (such as a time tracking device). This option is entirely dependent upon the third-party vendor’s Integration setup, and when available, should include instructions in the Vendor Integration Setup section below.

### Starting the generate secret workflow
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/4039db4e-c90b-4d63-9339-f481616b7095)

If you clicked the Generate Secret button above, you will automatically begin the Generate Secret Workflow. However, if you clicked the Close button instead, or you otherwise need to generate a new secret for an Integration, you can navigate to the Integration Accesses tab (1) on the Integration Details screen, as explained above, and look at the Can Generate Secret column (2) to see if you are allowed to generate a secret.  If you can generate a secret, you can click the down arrow on the row (3) and click the Generate Secret button to start the workflow, and you can continue the workflow as outlined in the Completing the Add Integration Access step above.

### Completing the workflow
![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/12a308e4-2e5e-4fe4-ab3b-6a82538a96d0)

After starting the Generate Secret Workflow, you will need to copy the Secret that is generated from the box on the screen.  To make this easy, you can click the Copy (1) button.  Once you have copied the information, you need to make sure the I Have Copied This Data (2) box has been checked (this will happen automatically when you click the Copy button), then click the Run Process (3) button to complete the process.




## Configure HelloID
1.	Login to the HelloID Instance and open the provisioning interface
2.	Add Source System
 
![image](https://github.com/Tools4everBV/HelloID-Conn-Prov-Source-Skyward-Qmlativ-Students/assets/24281600/644f303f-e638-4b80-b192-fb8682e1b8e3)

3.	Search the catalog for Skyward and choose the appropriate Qmlativ connector (e.g. Students, Employees, Staff), then click “+ Create”
 
![image](https://github.com/Tools4everBV/HelloID-Conn-Prov-Source-Skyward-Qmlativ-Students/assets/24281600/cad3e703-4a4a-4376-a1ea-9937fb4b3f22)

4.	Open the Source System, and go to the “Configuration” Tab

![image](https://github.com/Tools4everBV/HelloID-Conn-Prov-Source-Skyward-Qmlativ-Students/assets/24281600/d81c2009-c2ad-4bb5-ad83-c9a8db40a03b)

5.	Enter the necessary connection information
    -	Customer/tenant ID
        -	This is the URL to the instance, typically in this format
        -	https://<Customer>.skyward.com/<customer>API
    -	Client ID
        -	Enter the Client Key from the Skyward integration Access Screen
    -	Client Key
        - Enter the Client Secret from the Skyward Integration Access Screen
    -	Integration Key
        -	Please reach out to Tools4ever support (support@tools4ever.com) to obtain this key. This key is generated on a per customer basis for access to use the integration
    -	Entity ID
        -	Typically, this is going to be “1”. It is the ID of the District we’ll be connecting to for this instance. In cases where there are multiple districts under one instance, then a system per district is required.
    - School Year ID
        -	This can remain blank and it will refer to the default active school year. Otherwise, you can specify a specific school year to target
    -	Fiscal Year ID
        -	This can remain blank and it will refer to the default active fiscal year. Otherwise, you can specify a specific fiscal year to target
6.	Click Apply
7.	Go back to Systems Overview and click “Start Import”
 
 ![image](https://github.com/Tools4everBV/HelloID-Conn-Prov-Source-Skyward-Qmlativ-Students/assets/24281600/54ccecb8-62ca-4d21-add1-1dadf308adef)



 
# HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
