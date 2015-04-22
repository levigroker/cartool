cartool
=======

Export images from OS X / iOS `.car` CoreUI archives.

#### Usage

	cartool <car_file> [output_directory]

`cartool` is a command line utility which takes two parameters:
	
* `<car_file>` is required and is the location and name of the `.car` file to extract.
* `[output_directory]` is optional and is the output path to extract the images from the
    `.car` file. If not specified, the current directory will be used.
	
Example:

    cartool ./path/to/Assets.car ~/Desktop/car_images
    
This will extract all images from the specified `Assets.car` file to a directory on the
user's Desktop called `car_images` (which should exist prior to using the tool).

### Installing

Build and archive, then export "Save Built Products".
Move the `cartool` executable into `/usr/local/bin`

#### Disclaimer and Licence

* Forked from [https://github.com/G-P-S/cartool](https://github.com/G-P-S/cartool) which
      was forked from [https://github.com/steventroughtonsmith/cartool](https://github.com/steventroughtonsmith/cartool).
* All new work is licensed under the [Creative Commons Attribution 3.0 Unported License](http://creativecommons.org/licenses/by/3.0/).
  Please see the included LICENSE.txt for complete details.

#### About

A professional iOS engineer by day, my name is Levi Brown. Authoring a blog
[grokin.gs](http://grokin.gs), I am reachable via:

Twitter [@levigroker](https://twitter.com/levigroker)  
App.net [@levigroker](https://alpha.app.net/levigroker)  
Email [levigroker@gmail.com](mailto:levigroker@gmail.com)  

Your constructive comments and feedback are always welcome.
