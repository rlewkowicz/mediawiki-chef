Containerized Mediawiki 
=======================
What is it? 
Installing media wiki is a bit of a pain. The directions are sometimes unclear on which packages are required for the php compile. At the very least in a platform agnostic manner. Theoretically this may even work with windows. As it stands it should work with either debian or red hat based systems. 

TODO: 
Write an installer that utilizes chef in an decentralized manner. 
All confs need to be templated to match the node attributes.
Probably going to put media wiki in with php container. I could also just have a build box for media wiki that pulls the code and installs the deps. Idk yet. 
I'd like to write sys d start stop for the containers. 


Requirements
------------
Just docker! (todo: remove the mariadb package)

Attributes
----------
TODO: List your cookbook attributes here.

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Ryan Lewkowicz
