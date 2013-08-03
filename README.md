# FastApp
# Derived from MongoDB Browser Example App

Designed to give you very fast database driven apps 

Uses Sintra, Mongodb and Ruby to make it fast and simple



Supports the following:

* Create Tables(collections)
* Drop empty Tables(collections)
* Create Row(document) in a collection
* Edit Row(document) 
* Delete document
* Validates JSON in browser before posting document add or update

New functionality
* Moved to traditional table view, without id
* Added search functionality http://tablename?field1=value1&field2=value1,value2,value3,
* Adding fields= pareamter to url processing - http://tablename?fields=name,country
* Added a Report Writer - Using a "mashup", and combining with the ability to search as well as page_size=0 to generate tables
* added special field processing for fields named "url", which will automatically become the records default "view", good for
  implementing "report" tables
* Added ability to pull a .xml file from a document via adding .xml to end
  (Preparation for auto-generaiton of w2ui javascript)
* Added w2ui-1.2 javascript components to public folder
* Started dbschema, for generation of schema generation, as well as
  full automatic gui (Coming soon)

