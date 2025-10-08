function [TauValues,FirstTauValues,exptype] = brukertaus_jsh(BrukerParameters)

% Function to extract tau-values and experiment type for 4pHYSCORE and 6pHYSCORE bruker data
% Modified from an original from https://github.com/DanielK2012/Hyscorean
% on 20251008 by JSH. 

if isfield(BrukerParameters,'PlsSPELPrgTxt')
    %--------------------------------------------------------------
    % Data acquired by PulseSPEL-HYSCORE experiments
    %--------------------------------------------------------------
    
    %Extract the PulseSpel code for the experiment
    PulseSpelExp = BrukerParameters.PlsSPELEXPSlct;
	% Check if this is a 6P HYSCORE experiment; put here for easy reference
	% below
	IsThis6PHy = strcmp(PulseSpelExp,'6P HYSCORE') | strcmp(PulseSpelExp,'6pHYSCORE') | strcmp(PulseSpelExp,'6PHYSCORE') | strcmp(PulseSpelExp,'6P_HYSCORE') | strcmp(PulseSpelExp,'6P HYSCORE multitau');  % This may fail if non-standard name has been used for experiment! I have included a few possibilities. 
	
    PulseSpelProgram = BrukerParameters.PlsSPELPrgTxt;
    %Find Indices to only scan executed PulseSpel experiment
	expN = regexp(PulseSpelProgram,['begin\s*(exp\d*)\s*"',PulseSpelExp,'"'],'tokens'); % First, find HYSCORE experiment number - note: beware of non-standard names, makes it harder to check for 6P HYSCORE! 
	ProgStartIndex = regexp(PulseSpelProgram,['begin\s*',expN{1}{1}],'start'); % Second, find index of first character of selected experiment
	ProgEndIndex = regexp(PulseSpelProgram,['(end\s*',expN{1}{1},')'],'end'); % Third, find index of last character of selected experiment

    if isempty(ProgStartIndex) % in case exp. name is not defined in PulseSpel
        ProgStartIndex = 1; % From original function - this is still useful! 
	end

	SelectedProgTxt = PulseSpelProgram(ProgStartIndex:ProgEndIndex); % New variable containing the text of the selected experiment

	% Find tau value d1 (only tau for 4P, first of two for 6P)
	toks = regexp(SelectedProgTxt,'d1\s*=\s*(\d*)','tokens'); % Defines tau for 4P HY (and tau1 for 6P) as d1
	for qq = 1:numel(toks)
		TauValues(qq) = str2double(toks{qq}{1}); 
		FirstTauValues = NaN; % Do not set second tau values when not using 6P HY
	end

	% Find tau value d2 (only for 6P, second of two for 6P)
	if IsThis6PHy
		toks6p = regexp(SelectedProgTxt,'d2\s*=\s*(\d*)','tokens'); % Defines tau2 for 6P HY as d2
		for qq = 1:numel(toks6p)
			FirstTauValues(qq) = str2double(toks6p{qq}{1});
		end
	end
    
    if ~exist('TauValues','var')
		PulseSpelVariables = BrukerParameters.PlsSPELGlbTxt;

		% Extract tau value directly with regexp
		toks = regexp(PulseSpelVariables,'d1\s*=\s*(\d*)','tokens'); % Defines d1 as tau1
		TauValues = str2double(toks{1}{1}); 

		% If this is a 6P HYSCORE experiment, extract the second tau value
		if IsThis6PHy
			toks6p = regexp(PulseSpelVariables,'d2\s*=\s*(\d*)','tokens'); % Defines d2 as tau2
			FirstTauValues = str2double(toks6p{1}{1}); 
		else
			FirstTauValues = NaN; % Do not set for 4P HYSCORE

		end


  	end

	if numel(FirstTauValues) ~= numel(TauValues)          % Check if the numbe of tau-values match
		warndlg('Read in of tau-values for 6pHYSCORE did not work out, number of tau1 values not equal to number of tau2 values read in','warning');
	end
    
else
    %--------------------------------------------------------------
    % Data acquired by XEPR-HYSCORE experiments
    %--------------------------------------------------------------
    
    %Get the field with the tau-value
    TauString = BrukerParameters.FTEzDelay1;
    %Convert to double
    Pos = strfind(TauString,' ns');
    TauValues = str2double(TauString(1:Pos));
    
end

% Store the experiment type
if strcmp(BrukerParameters.PlsSPELEXPSlct,'6P HYSCORE') | strcmp(BrukerParameters.PlsSPELEXPSlct,'6pHYSCORE') | strcmp(BrukerParameters.PlsSPELEXPSlct,'6PHYSCORE') | strcmp(BrukerParameters.PlsSPELEXPSlct,'6P_HYSCORE') | strcmp(BrukerParameters.PlsSPELEXPSlct,'6P HYSCORE multitau')  % This may fail if non-standard name has been used for experiment! I have included a few possibilities. 
    exptype = '6pHYSCORE';
else
    exptype = '4pHYSCORE';
end
  

end
