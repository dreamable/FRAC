#/bin/sh
echo ""
echo "Installing COHO Reachabilty Analysis Tool ......" 
echo ""

echo "====Step0: Set environment variable RAC_HOME====" 
RAC_HOME=`pwd`
export RAC_HOME
echo $RAC_HOME
echo "" 

echo "====Step1: Install JANS ===" 
rm -rf JANS
git clone https://github.com/dreamable/JANS.git
cd JANS
sh install.sh

echo "====Step2: Generating RAC configuration file ====" 
cd $RAC_HOME
while true; do 
	echo "The commerical LP solver CPLEX may speedup the RAC computation."
	echo "  We use the CPLEXINT interface to use CPLEX in Matlab." 
	echo "  For more details, please check http://control.ee.ethz.ch/~hybrid/cplexint.php."
	echo "  If you want to use CPLEX solver, please configurate your system to make cplexint.m under LinearProgramming/Solver/CPLEX work." 
	read -p "Is CPLEX LP solver available in your system? " yn 
	case $yn in 
		[Yy]* ) has_cplex=1; break;; 
	  [Nn]* ) has_cplex=0; break;;
	  * ) echo "Please answer yes or no.";; 
	esac 
done

echo "
% function val = rac_info(field)
%   This function returns read-only information for RAC, including: 
%     rac_home:  root path of CAR software 
%     rac_dirs:  all RAC dirs to be added in Matlab
%     user:      current user
%     has_cplex: CPLEX LP solver is available or not in the system 
%     version:   RAC version
%     license:   RAC license
%  Ex: 
%     info = rac_info;  // return the structure
%     has_cplex = rac_info('has_cplex'); // has the value
function val = rac_info(field)
  % NOTE: I use global vars because of the Matlab bug. 
	%       (When the code is in linked dir, persistent vars are re-inited 
	%        when firstly changing to a new directory). 
  %       Please don't modify the value by other functions. 
  %persistent  RAC_INFO;
  global RAC_INFO;
  if(isempty(RAC_INFO)) 
    RAC_INFO = rac_info_init; % evaluate once
  end
  if(nargin<1||isempty(field))
    val = RAC_INFO;
  else
    val = RAC_INFO.(field);
  end; 
end
function  info = rac_info_init
  % RAC root path
  rac_home='`pwd`'; 

  % RAC directories 
  rac_dirs = {
    'ConvexPh',
    'LinearProgramming',
    'LinearProgramming/Project',
    'LinearProgramming/Solver',
    'Polygon',
    'Polygon/SAGA',
    'Integrator',
    'JANS',
    'Utils',
    'Utils/Logger'};

  % cplex is avail in the system
  has_cplex = $has_cplex; 
  
  % current user
  [~,user] = unix('whoami');
  user = user(1:end-1);

	% path to save RAC system data or files
  sys_path = ['/var/tmp/',user,'/coho/rac/sys']; 

  version = 1.1;
  license = 'bsd';
  
  info = struct('version',version, 'license',license, ...
                'rac_dirs',{rac_dirs}, 'rac_home',rac_home, ...
                'user',user, 'has_cplex', has_cplex, ...
                'sys_path', sys_path); 
end % rac_info
" > rac_info.m

echo "You can update the configurations later by editing rac_info.m file."

echo ""
echo "COHO Reachabilty Analysis Tool Installed!" 
echo ""
