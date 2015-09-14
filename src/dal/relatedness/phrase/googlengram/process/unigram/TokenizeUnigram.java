package dal.relatedness.phrase.googlengram.process.unigram;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.LinkedHashMap;

import dal.relatedness.phrase.googlengram.process.constant.Constants;

public class TokenizeUnigram {
	public void tokenizeUnigram(){
		try{
			String sCurrentLine;
			LinkedHashMap<String,Long> hmTokens = new LinkedHashMap<String, Long>();

			BufferedReader br = new BufferedReader(new FileReader(Constants.uniGramFilePath));

			while ((sCurrentLine = br.readLine()) != null) {
				String arr[] = sCurrentLine.toLowerCase().split("\t");
				//System.out.println(arr[0]+","+arr[1]);
				if(!hmTokens.containsKey(arr[0])){
					hmTokens.put(arr[0], Long.parseLong(arr[1]));
				}else{
					hmTokens.put(arr[0], hmTokens.get(arr[0]) + Long.parseLong(arr[1]));
				}
			}
			
			br.close();
			
			System.out.println(hmTokens.size());
			
			int count =0;
			PrintWriter pr = new PrintWriter(Constants.tokenizedUniGramFilePath);
			
			for(String key : hmTokens.keySet()){
				pr.println(key+"\t"+count+"\t"+hmTokens.get(key));
				count++;
			}
			
			pr.close();
			

		}catch(IOException e){
			e.printStackTrace();
		}
	}
}
