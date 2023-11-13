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
  - [General Notes](#general-notes)
  - [API User](#api-user)
  - [API User Access](#api-user-access)
  - [Integration Access Secrets](#integration-access-secrets)
- [Configure HelloID](#configure-helloid)
- [HelloID docs](#helloid-docs)


## Available Data
Access to data is controlled by Skyward approval. Please refer to the [Intergation Access XML](/IntegrationAccess.xml) for specifics to which table and fields are available. Also, it refers to what CRUD action are available as well.

## Setting up the API Access
### General Notes
Each API Vendor should have an Integration record available in Qmlativ.

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/64e32e13-72a4-466e-a453-cb0ac99aa9ad)

The APIs used by an Integration can also be viewed from the Integration List screen by looking at the lower browse.  The APIs may also be viewed from the Integration APIs tab on the Integration Details screen.

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/e629fce7-210e-4eac-8cf8-7c1e84ec4d37)

If the vendor has indicated that they are using the Custom API, select it to see which Objects and Fields are being used, and what types of access they have to them.

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/2a5f2eff-4c45-4ba1-a5c8-b6dfb29cc781)

An Integration Access record is required to grant Qmlativ API access, similar to the API User record.
If the vendor has requested to set up new Integration Access credentials and their Integration is not visible in the Integration List, please reach out to Skyward to ensure that the Integration Sync process is working properly.

### API User
A new Integration Access record should exist for each active API User record.
API User records may be found under the API area by selecting the User feature:

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/13404ad4-8452-4efa-92a1-505245b443a8)

You may find/create Integration Access records by going to the API area and select the Integration Access feature:

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/2441eb2e-3bb1-40f2-a823-f6a65cfffe88)

Integration Access records can also be found/created from the Integration Details screen.

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/19180006-f55e-40c3-864d-16a5bdc821b4)

It is recommended to copy most of the API User’s settings into the Integration Access.

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/5764c1ec-85ad-4138-b6b5-273af858544e)

![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/153329dc-a7d7-4f4f-87bc-b543391212ab)

The areas highlighted in red (1-4) can be taken from the API User record. The area highlighted in blue (5) can be taken from the API User Access records associated with the API User record. These values can also be changed to something new but keeping them the same reduces the possibility of errors during the initial conversion.

**NOTE**: _OAuth1 as an Authentication Type has been removed for the Integration Access system. Each vendor that used OAuth1 should migrate to OAuth2 for the new Integration Access system._

### API User Access

One of the main benefits of the Integration Access system is that each Integration is already pre-packaged with which APIs it uses, and therefore with which configuration records it is associated. When configuring an Integration Access, selecting the vendor’s Integration will automatically display the expected API Configuration sections.
Here is an example of the Integration Access screen when the selected Integration uses all APIs. As you can see, the Configuration section displays all configuration options for the APIs:

 ![image](https://github.com/Tools4ever-NIM/NIM-System-REST-Skyward-Qmlativ/assets/24281600/1318e043-58d0-48c3-89d5-4dab27c9ff71)

**NOTE:** _OneRoster, Time Tracking, Identification, Attendance, and Enrollment Configuration records can be shared between the API User Access and Integration Access records._

Custom API Entities is a new entity selector that controls which entities the vendor has access to.  For Integrations that use the Custom API, the modules, objects, and fields that are used by the Integration are now visible on the “Integration Objects” tab, so the old “Allow Security Module Write Operations” checkbox that was on the API User Access is now obsolete.

### Integration Access Secrets
Secrets work differently in the Integration Access system than they did in the API User system. In all situations, it is not possible for districts to generate their own complete set of API credentials. 

* For vendors who do not enable the district to create their own Secret, only a Key and Secret is required to authenticate themselves in the Qmlativ API. 
* For vendors who enable the district to create their own Secret, there is a hidden third value stored by the vendor that enables the Integration Access connection.

Secrets generated for Integration Access can only be viewed once; they cannot be retrieved after closing the confirmation dialog.


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
