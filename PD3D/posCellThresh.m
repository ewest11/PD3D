function [posCellTable] = posCellThresh(PPCtable,numpuncta)
%% This function applies a threshold for calling cells "positive" for a marker if they contain >npuncta puncta

posCellTable=PPCtable(PPCtable.npuncta>numpuncta,:); 



end

