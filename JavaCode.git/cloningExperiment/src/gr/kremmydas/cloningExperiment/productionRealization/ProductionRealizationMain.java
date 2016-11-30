package gr.kremmydas.cloningExperiment.productionRealization;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;

/**
 * Outputs a file of this type {yields.txt, prices.txt}
 * dw                    200.00
 * mze                   250.00
 * sfl                   250.00
 * cot                  1240.00
 * tob                   700.00
 * @author jkr
 *
 */

public class ProductionRealizationMain {
	
	private ArrayList<String> crops = new ArrayList<>();
	
	private HashMap<String,Float> yields = new HashMap<>();
	
	private HashMap<String,Float> prices = new HashMap<>();
	
	private ArrayList<Double> rnd = new ArrayList<>();
	
	private int curRndIndex;

	/**
	 * Run the production realization
	 * 
	 *  args[0]:the crops.txt 
	 *  args[1]:the yields output file       
	 *  args[2]:the prices output file 
	 *  args[3]:the seed file
	 *  args[4]:the seed index file
	 * 
	 * 
	 * @param args
	 * 
	 */
	public static void main(String[] args) {
		ProductionRealizationMain pr = new ProductionRealizationMain();
		
		//load rnd and its current position
		pr.readSeedIndex(args[4]);
		pr.buildRnd(args[3]);	
		System.out.println("Random current Index:"+pr.curRndIndex);
		
		
		pr.init();		
		pr.readFile(args[0]);
		pr.calculatePrices(args[2]);
		
		pr.writeFile(args[1],pr.yields);
		pr.writeFile(args[2],pr.prices);
		
		pr.writeSeedIndex(args[4]);
		
		System.out.println("-- Yields: " + pr.yields.toString());
		System.out.println("-- Prices: " + pr.prices.toString());

	}
	
	private void init() {
		this.yields.put("dw",3.5f);this.yields.put("mze",9f);this.yields.put("sfl",5f);
		this.yields.put("cot",1.9f);this.yields.put("tob",2f);
	}
	
	private void calculatePrices(String prePricesFile) {
		
		//read file
		Scanner sc = null;
		try {
			sc = new Scanner(new FileReader(prePricesFile));
			sc.useDelimiter(System.getProperty("line.separator"));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		while (sc.hasNext()){
		    	String line=sc.next();	    	
		    	if(! line.isEmpty()) {
		    		String[] spl=new String[2];
			    	spl = line.split("\\s+");
			    	this.prices.put(spl[0], Float.valueOf(spl[1]));
		    	}
		  }
		
		//claculate small adjustments of +-30%
		for(String c : this.prices.keySet()) {
			Float pr = this.prices.get(c);
			Double r1 = this.rnd.get(this.curRndIndex++);
			Double r2 = this.rnd.get(this.curRndIndex++);
			Float newPr = (float)( pr*(1+0.3*(r1-r2)));
			if(newPr.compareTo(50.0f)==0) {newPr=50f;}
			this.prices.put(c, newPr);
		}
		
	}
	
	private void buildRnd(String inFile) {
		Scanner sc = null;
		try {
			sc = new Scanner(new FileReader(inFile));
			sc.useDelimiter(System.getProperty("line.separator"));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	    while (sc.hasNext()){
	    	String line=sc.next();	    	
	    	this.rnd.add(Double.valueOf(line));
	    }
	}
	
	private void readFile(String inFile) {
		Scanner sc = null;
		try {
			sc = new Scanner(new FileReader(inFile));
			sc.useDelimiter(System.getProperty("line.separator"));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	    while (sc.hasNext()){
	    	String line=sc.next();	    	
	    	if(! line.isEmpty()) {this.crops.add(line);}
	    }
	}
	
	private void readSeedIndex(String inFile) {
		Scanner sc = null;
		try {
			sc = new Scanner(new FileReader(inFile));
			sc.useDelimiter(System.getProperty("line.separator"));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	    	String line=sc.next();	    	
	    	this.curRndIndex=Integer.parseInt(line.trim());
	    
	}
	
	
	private void writeFile(String outFile,HashMap<String,Float> values) {
		String r = "";
		String format="%s\t%.3f";
		for(String f :values.keySet()) {
			r += String.format(format, f,values.get(f));
			r += System.getProperty("line.separator");
		}
	
		try (Writer writer = new BufferedWriter(new OutputStreamWriter(
	              new FileOutputStream(outFile), "utf-8"))) {
		   writer.write(r);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void writeSeedIndex(String outFile) {

		try (Writer writer = new BufferedWriter(new OutputStreamWriter(
	              new FileOutputStream(outFile), "utf-8"))) {
		   writer.write(String.valueOf(this.curRndIndex));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
