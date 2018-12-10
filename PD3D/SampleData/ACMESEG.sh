
#declare -A TEST




#$1= resampled filename
#$2=rescale factor
#$3 = planarity argument
#$4 = TV argument
#$5= watershed argument


	
				echo "Doing file "$1
	
		
		/Users/emmawest/Desktop/SABER/ACME/resample $1.mha $1_resample.mha $2 $2 1

		/Users/emmawest/Desktop/SABER/ACME/multiscalePlateMeasureImageFilter $1_resample.mha $1_P.mha $1_EF.mha $3

		/Users/emmawest/Desktop/SABER/ACME/membraneVotingField3D $1_P.mha $1_EF.mha $1_TV.mha $4

		/Users/emmawest/Desktop/SABER/ACME/membraneSegmentation $1_resample.mha $1_TV.mha $1_wat$5.mha $5
		
		rm $1_TV.mha
		rm $1_P.mha
		rm $1_EF.mha

3A


