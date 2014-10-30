# Description

This [dashing](https://github.com/Shopify/dashing) widget allows to retrieve iand display Active visitors count from Google Analytics real-time API.  
It supports multiple `profile_id` as well as custom grouping.

It was inspired from:

- [Google Analytics visitor count (OAuth2) fork to support real time](https://gist.github.com/robertboloc/9546339) for real-time API support
- [Google Analytics visitor count (OAuth2) fork to support multiple sites](https://gist.github.com/willjohnson/6232286) for multi-profile support

# Dependencies

[google-api-ruby-client](https://github.com/google/google-api-ruby-client)

Add it to dashing's gemfile:
```
gem 'google-api-client'
```
and run `bundle install`.

# Usage
To use this widget, you'll first need to set up a Google API project and attach it to the Google Analytics profile you wish to monitor.

### 1. Create and download a new private key for Google API access. ####

1.  Go to https://code.google.com/apis/console
2.  Click 'Create Project'
3.  Enable 'Analytics API' service and accept both TOS's
4.  Click 'API Access' in the left-hand nav menu
5.  Click 'Create an OAuth 2.0 Client ID'
6.  Enter a product name (e.g. Dashing Widget) - logo and url are optional
7.  Click 'Next'
8.  Under Application Type, select 'Service Account'
9.  Click 'Create Client ID'
10.  Click 'Download private key'  NOTE: This will be your only opportunity to download this key.
11.  Note the password for your new private key ('notasecret')
12.  Close the download key dialog
13.  Find the details for the service account you just created and copy it's email address which will look something like this: `210987654321-3rmagherd99kitt3h5@developer.gserviceaccount.com` - you'll need it in your ruby code later

### 2. Attach your Google API service account to your Google Analytics profile ####
_Note: you will need to be an administrator of the Google Analytics profile_

1. Log in to your Google Analytics account:  http://www.google.com/analytics/
2. Click 'Admin' in the upper-right corner
3. Select the account containing the profile you wish to use
4. Select the property containing the profile you wish to use
5. Select the profile you wish to use
6. Click the 'Users' tab
7. Click '+ New User'
8. Enter the email address you copied from step 13 above
9. Click 'Add User'

If you want to use multi-profile feature, you'll need to add your Google API ccount to **each** profile.

### 3. Locate the ID for your Google Analytics profile ####

1. On your Google Analytics profile page, click the 'Profile Settings' tab
2. Under 'General Information' copy your Profile ID  (e.g. 654321) - you'll need it in your ruby code later

### 4. Start coding (finally) ####

1.  Copy the `visitor_count.rb` file in to your dashing `jobs\` folder.
2.  Update the `service_account_email`, `key_file`, `key_secret` and `profiles` variables
```ruby

    service_account_email = '[YOUR SERVICE ACCOUTN EMAIL]' # Email of service account
    key_file = 'path/to/your/keyfile.p12' # File containing your private key
    key_secret = 'notasecret' # Password to unlock private key
    # Array of profile names and corresponding Analytics profile id
    profiles = [{name: 'site1', group: 'Group1', id: '11111111'},
                {name: 'site2', group: 'Group1', id: '22222222'},
                {name: 'site3', group: 'Group2', id: '33333333'},
                {name: 'site4', group: 'Group3', id: '44444444'}]
```
3. Add the widget HTML to your dashboard

Groups allows you to choose which widget will display which metric.  
For example, you can choose to display active visitors on your Web site on one widget, while displaying Mobile users on another.

```html 

    <li data-row="1" data-col="1" data-sizex="1" data-sizey="1"> 
      <div data-id="ga_rt_active_users_Group1"
           data-view="Rickshawgraph"
           data-renderer="area"
           data-title="Group1 active users"
           data-legend="true"
           data-summary-method="sumLast" ></div>
    </li>

    <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-id="ga_rt_active_users_Group2"
           data-view="Rickshawgraph"
           data-renderer="area"
           data-title="Group2 active users"
           data-legend="true"
           data-summary-method="sumLast" ></div>
    </li>

    <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
      <div data-id="ga_rt_active_users_Group3"
           data-view="Rickshawgraph"
           data-renderer="area"
           data-title="Group=3 active users"
           data-legend="true"
           data-summary-method="sumLast" ></div>
    </li>

```

# Notes

If you want to modify this plugin to pull other data from Google Analytics, be sure to check out the [Google Analytics Query Explorer](http://ga-dev-tools.appspot.com/explorer/).
