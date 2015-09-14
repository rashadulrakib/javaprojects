package dal.relatedness.phrase.googlengram.process.bigram;

import java.io.File;

import org.apache.log4j.Logger;

import dal.relatedness.phrase.googlengram.process.constant.Constants;

public class TokenizeBigram {
	
	Logger LOGGER = Logger.getLogger(TokenizeBigram.class);
	
	public void tokenizeBigram(){
		try{
			File folder = new File(Constants.biGramDir);
			File[] listOfFiles = folder.listFiles();

			for (File file : listOfFiles) {
			    if (file.isFile()) {
			    	LOGGER.info(file.getName());
			        
			    }
			}
		}catch(Exception e){
			e.printStackTrace();
		}
	}
}
