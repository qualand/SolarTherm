import pytest
import subprocess as sp
import shutil, platform, os
from pathlib import Path

def test_1():
	exe = './testdispatch'
	env = None
	if platform.system()=="Linux":
		env = os.environ.copy()
		env['LD_LIBRARY_PATH']='../src/modelica'
	fdni = Path("../SolarTherm/Data/Weather/Mildura_Real2010_Created20130430.motab")
	fprice = Path("../SolarTherm/Data/Prices/aemo_vic_2014_hourly_manipulated.motab")
	t = 180.0
	proc = sp.run([exe,str(fdni),str(fprice),str(t)],env=env)#stdout=sp.PIPE,stderr=sp.PIPE,env=env)
	assert(proc.returncode==0)

def test_2():
	exe = './testdispatch2'
	env = None
	if platform.system()=="Linux":
		env = os.environ.copy()
		env['LD_LIBRARY_PATH']='../src/modelica'
	proc = sp.run([exe],env=env)
	assert(proc.returncode==0)

