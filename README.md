# HelloID-Conn-Prov-Target-Ultimo

| :warning: Warning |
|:---------------------------|
| Ultimo uses a generic User API which needs to be configured for each customer by an Ultimo consultant. Therefore this connector will **not work** out of the box without assistance from a Ultimo consultant and HelloID consultant       |

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |
<br />
<p align="center"> 
  <img src="https://www.tools4ever.nl/connector-logos/ultimo-logo.png">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-Ultimo](#helloid-conn-prov-target-ultimo)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Getting started](#getting-started)
      - [Configuration Settings](#configuration-settings)
  - [Design considerations](#design-considerations)
- [HelloID Docs](#helloid-docs)

---

## Introduction

Ultimo is a flexible Enterprise Asset Management (EAM) Cloud platform with a REST-based web service to programmatically interact with its data. 
The HelloID target connector has the capability to create and update Ultimo accounts, as well as grant permissions to Ultimo groups, based on the connectors established within Ultimo.

> ❗ This connector only supports account provisioning in Ultimo. Employee provisioning is outside the scope for this connector.

## Prerequisites

 - Credentials to authorize to Ultimo
 - Import and Export connectors in Ultimo (**These connectors are customer-specific and usually created by Ultimo consultants**)
 - Employee is expected to be present in Ultimo before the account provisioning in HelloID starts

---

## Getting started

#### Configuration Settings
 
You must enter the URL and the API key of your Ultimo Environment. Additionally, you will need a GUID of objects to specify the request endpoint. This GUID refers to an object in the Connector in Ultimo. 

There are separate GUIDs for retrieving groups, retrieving users, and making update calls, all of which must be specified in the configuration of your connector.

![image](./UltimoExample..png)

---

## Design considerations

- Create will create the user
- Delete will only revoke the groupAssignment
- Disable and Enable are not used. This is not possible in Ultimo

- Permission Grant, assigns the Group to an Ultimo user  (An Ultmio user can be a member of **one group at a time**. One to one relation)
- Permission Revoke is not used, because when you receive a new Group/Entitlement. HelloID triggers both events at the same time (Assignment of the new and revoke of the old assignment). With might result in ending up with an account without an entitlement. When the Grant event is first processed and the revoke event will eventually remove the entitlement again.

# HelloID Docs
The official HelloID documentation can be found at: https://docs.helloid.com/
