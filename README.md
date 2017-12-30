# MC2048

![MC2048](http://p0h33xrro.bkt.clouddn.com/MC2048_2048Header.png)

A simple 2048 Game implemented by Objective-C。

## Showcase

![Screen Shot](http://p0h33xrro.bkt.clouddn.com/MC2048_2048Screenshot.png)

![GIF Showcase](http://p0h33xrro.bkt.clouddn.com/MC2048_2048Showcase.gif)

## Requirement
- iOS 8.0+
- Xcode 7.2+
- Objective-C

## Tutorial
This application using MVC, the structure is as follows:

```
    .
    ├── MC2048
    │   ├── Classes：Base Class 
    │   │   ├── Mode：All the base class and animation class 
    │   │   ├── View：All the base view like block, score, peakScore, etc...
    │   │   └── Controller：The base controller
    │   ├── Home：The class of the home interface
    │   │   ├── Model：The custom transition class
    │   │   ├── Controller：All the mode interface
    │   ├── Etc：....
    │   │   ├── ....
    │   │   ├── ....
    │   │   └── ....
    │   └── Extension：Extension/ Catagory of system class
```

## Author
Minecode, [minecoder@163.com](mailto:minecoder@163.com)
