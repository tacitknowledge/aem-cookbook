# aem-cookbook

This cookbook installs and configures [Adobe Experience Manager (AEM)](http://www.adobe.com/solutions/web-experience-management.html). (NOTE: CQ versions 5.4 and 5.5 should work as well -- CQ was renamed to AEM as of version 5.6). Included are recipes to install an author or publish instance as well as the dispatcher module for Apache HTTP server.

## Supported Platforms

* CentOS

## Supported Versions

* AEM 6.0.0
* AEM 5.6.1
* AEM 5.6.0
* CQ 5.5.0

## Featured Functionality

* Unattended installation of aem author, publish, and dispatcher nodes.
* Automatically search for and configure aem cluster members (dispatcher, author, publish) using chef searches.
* Configure replication agents using the replicator provider.
* Configure dispatcher farms with the farm provider.
* Deploy and remove aem packages with the package provider (recommended for development purposes only).

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['aem']['version']</tt></td>
    <td>String</td>
    <td>AEM version</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['aem']['download_url']</tt></td>
    <td>String</td>
    <td>URL to AEM jar file</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['aem']['license_url']</tt></td>
    <td>String</td>
    <td>URL to AEM license file</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['aem']['dispatcher']['mod_dispatcher_url']</tt></td>
    <td>String</td>
    <td>URL to AEM dispatcher (.tar.gz or .so)</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['aem']['dispatcher']['version']</tt></td>
    <td>String</td>
    <td>dispatcher module version</td>
    <td><tt>nil</tt></td>
  </tr>
</table>

## Usage

### aem::author

Include `aem::author` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[aem::author]"
  ]
}
```

### aem::publish

Include `aem::publish` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[aem::publish]"
  ]
}
```

### aem::dispatcher

Include `aem::dispatcher` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[aem::dispatcher]"
  ]
}
```

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

- Author:: Bryce Lynn (<bryce@tacitknowledge.com>)
- Author:: Alex Dunn (<adunn@tacitknowledge.com>)
- Author:: Paul Dunnavant (<pdunnavant@tacitknowledge.com>)

```text
Copyright 2012-2016, Tacit Knowledge, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
