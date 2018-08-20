---
author: Levi Leal
layout: post
title:  "Messing Around with Python"
subtitle: "Introduction"
date:   2018-08-18 00:00:00 +0100
categories: Python, Metaprogramming
image: https://codez1.files.wordpress.com/2017/01/babys-first-steps-454.jpg
#excerpt: Há um bom tempo venho pensando em criar um site, blog, vlog
comments: True
---
Today I'll start a series of posts where I play around with python and show some interesting tricks you can do on it.

This series will address some metaprogramming concepts in python and how to use them.

We are going to use the version 3.6.0 of Python, but you can use any 3.3+. Don't try earlier versions because your computer can explode then.

So first of all, what is metaprogramming?

According to [Wikipedia](https://en.wikipedia.org/wiki/Metaprogramming)
>Metaprogramming is a programming technique in which computer programs have the ability to treat programs as their data. It means that a program can be designed to read, generate, analyse or transform other programs, and even modify itself while running.

In a nutshell, metaprogramming is code that manipulates code. Some common examples of doing it in Python is using: Decorators, Metaclasses or Descriptors.

So why would you care about this? Well, metaprogramming is extensively used in frameworks and libraries, you will get to know better how Python works, it solves a practical problem and, the most important of all, it's fun.

Sometimes when programming we repeat lots of code and that can turn into a problem later when we have to modify that because the same code would be on many places. There is a principle in software development that helps us not to fall in this issue. It's called DRY, that stands for Don't Repeat Yourself, that stands for Don't Repeat Yourself.

Here are some reasons why we should try to keep this principle: High repetitive code sucks, it is tedious to write, it is also hard to read and it is difficult to modify.

This series go for anyone who: want to build a framework/library or is just curious about how things work.  