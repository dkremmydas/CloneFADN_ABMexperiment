package gr.kremmydas.cloningExperiment.landmarket;

import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Random;
import java.util.Scanner;

/**
 * <p>The input file format is as follows:</p>
 * <ul>
 * <li>Each row contains information for one farm</li>
 * <li>	Column 1: farm id, 
 * 		Column 2: Land supply of farm, 
 * 		Column 3: WTA, 
 * 		Column 4: Land demand of farm,
 * 		Column 5: WTP</li>
 * </ul>
 * 
 * @author Dimitri Kremmydas
 *
 */
public class LandMarketMain {

	/**
	 * Runs the Land Market
	 * 
	 * @param args 1st:the input file containing farm data, 2nd:the output file, 3nd:number of loops, 4th:log file
	 */
	
	private HashMap<String,FarmInputProperties> farmInput = new HashMap<>();
	private HashMap<String,FarmOutputProperties> farmOutput = new HashMap<>();
	private int loops;
	private String logResult="loop\tb_id\twtp\ts_id\twta\tland\tprice\tcash";
	
	private ArrayList<Double> rnd = new ArrayList<>();
	private int curRndIndex;
	
	/**
	 * args[0]: (string) input.txt 
	 * args[1]: (string) output.txt
	 * args[2]: (int) Number of iterations
	 * args[3]: (string) log file name
	 * args[4]: (string) random numbers file
	 * args[5]: (string) random number pointer file
	 * @param args
	 */
	public static void main(String[] args) {
		
		if(args.length==0) {System.exit(1);}
		
		LandMarketMain m = new LandMarketMain();
		m.loops = Integer.parseInt(args[2]);
		if(m.loops==0) {System.exit(2);}
		m.readSeedIndex(args[5]);
		m.buildRnd(args[4]);		
		m.readInput(args[0]);
		
		m.clearMarket(m);		
		m.writeOutput(args[1]);
		m.writeLog(args[3]);
		m.writeSeedIndex(args[5]);

		System.exit(0);	
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
	
	
	private void clearMarket(LandMarketMain m) {
		
		ArrayList<String> sellers = new ArrayList<>();
		ArrayList<String> buyers = new ArrayList<>();
		
		//construct sellers-buyers list
		for(String f : m.farmInput.keySet()) {
			if(m.farmInput.get(f).LandSupply>0) {sellers.add(f);}
			if(m.farmInput.get(f).LandDemand>0) {buyers.add(f);}
		}
		
		System.out.println("-- NumOfSellers:"+sellers.size() + "  NumOfBuyers:"+buyers.size());
		
		//get random numbers
		//HashMap<String,Double> sellers_score = 
				
		//		(ArrayList<Double>) this.rnd.subList(this.curRndIndex, this.curRndIndex+sellers.size());
		for(String f: sellers) {sellers_score=*((double)this.farmInput.get(f).getWtp());}
		this.curRndIndex=+sellers.size();
		
		ArrayList<Double> buyers_score = (ArrayList<Double>) this.rnd.subList(this.curRndIndex, this.curRndIndex+buyers.size());
		this.curRndIndex=+buyers.size();
		
		
		//get sorted buyers
		ArrayIndexComparator comparator = new ArrayIndexComparator(sellers_order);
		
		
		for(int i=0;i<m.loops;i++) {
			
			this.logResult+=System.getProperty("line.separator")+String.valueOf(i)+"\t";
			
			//System.out.println();System.out.println("Loop:"+i);
			
			//if no sellers or no buyers then exit
			if(sellers.isEmpty() || buyers.isEmpty()) {break;}
			
			
			//select a random buyer-farm
			String bf = buyers.get(new Random().nextInt(buyers.size()));
			this.logResult+=bf+"\t"+this.farmInput.get(bf).getWtp()+"\t";
			
			//select a random seller-farm
			String sf = sellers.get(new Random().nextInt(sellers.size()));
			this.logResult+=sf+"\t"+this.farmInput.get(sf).getWta()+"\t";
			
			if(sf==bf) {continue;}
			
			//System.out.println("Bf:"+bf+ " wtp:"+farmInput.get(bf).getWtp()+ " / Sf:"+sf+" wta:"+farmInput.get(sf).getWta());
			
			//if buyer-WTP>seller-WTA get a random price between and make the transaction
			if(farmInput.get(bf).getWtp()>farmInput.get(sf).getWta()) {
				//transaction means to update farmOutput and adjust farmInput and sellers/buyers list
				float landTrans = (farmInput.get(bf).getLandDemand()<farmInput.get(sf).getLandSupply())?farmInput.get(bf).getLandDemand():farmInput.get(sf).getLandSupply();
				float price = farmInput.get(bf).getWtp()-(farmInput.get(bf).getWtp()-farmInput.get(sf).getWta())*(new Random().nextFloat());

				this.logResult+=landTrans+"\t"+price+"\t"+(landTrans*price);
				
				//update demand supply
				farmInput.get(bf).setLandDemand(farmInput.get(bf).getLandDemand()-landTrans);
				farmInput.get(sf).setLandSupply(farmInput.get(sf).getLandSupply()-landTrans);
				
				//update buyers/sellers list
				if(farmInput.get(bf).getLandDemand()<0.1) {buyers.remove(bf);}
				if(farmInput.get(sf).getLandSupply()<0.1) {sellers.remove(sf);}
				
				//update cash
				farmOutput.get(bf).setCash(-1*(landTrans*price));
				farmOutput.get(bf).setRentedIn(landTrans);
				
				farmOutput.get(sf).setCash(landTrans*price);
				farmOutput.get(sf).setRentedOut(landTrans);
			}
			else {
				this.logResult+="NA\tNA\tNA";
			}			
		}
		
	}
	
	private void writeOutput(String outFile) {
		String r = "";
		for(String f :this.farmOutput.keySet()) {
			FarmOutputProperties fop = this.farmOutput.get(f);
			String format="LandMarketOut('%s','%s')=%.3f;";
			r += String.format(format, f,"rentIn",fop.getRentedIn());
			r += String.format(format, f,"rentOut",fop.getRentedOut());
			r += String.format(format, f,"cash",fop.getCash());
			r += System.getProperty("line.separator");
			//System.out.println(r);
		}
	
		try (Writer writer = new BufferedWriter(new OutputStreamWriter(
	              new FileOutputStream(outFile), "utf-8"))) {
		   writer.write(r);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
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
	
	private void writeSeedIndex(String outFile) {

		try (Writer writer = new BufferedWriter(new OutputStreamWriter(
	              new FileOutputStream(outFile), "utf-8"))) {
		   writer.write(String.valueOf(this.curRndIndex));
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void writeLog(String outFile) {
		try(  PrintWriter out = new PrintWriter(outFile)  ){
		    out.println( this.logResult );
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private void readInput(String inFile) {
		Scanner sc = null;
		try {
			sc = new Scanner(new FileReader(inFile));
			sc.useDelimiter(System.getProperty("line.separator"));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		String[] split=new String[5];
	    while (sc.hasNext()){
	    	String line=sc.next();	    	
	    	split = line.split("\\t");
	        farmInput.put(split[0].trim(), new FarmInputProperties(split[1], split[2], split[3], split[4]));
	        farmOutput.put(split[0].trim(), new FarmOutputProperties(0,0,0));
	    }
	}
	
	private class FarmOutputProperties {
		private float rentedIn = 0;
		private float rentedOut = 0;
		private float cash = 0;
		
		public FarmOutputProperties(float rentedIn, float rentedOut, float cash) {
			super();
			this.rentedIn = rentedIn;
			this.rentedOut = rentedOut;
			this.cash = cash;
		}

		public float getRentedIn() {
			return rentedIn;
		}

		public void setRentedIn(float rentedIn) {
			this.rentedIn = rentedIn;
		}

		public float getRentedOut() {
			return rentedOut;
		}

		public void setRentedOut(float rentedOut) {
			this.rentedOut = rentedOut;
		}

		public float getCash() {
			return cash;
		}

		public void setCash(float cash) {
			this.cash = cash;
		}
		
		
	}
	
	private class FarmInputProperties {
		private float LandSupply;
		private float wta;
		private float LandDemand;
		private float wtp;
		
		
		public FarmInputProperties(float landSupply, float wta, float landDemand, float wtp) {
			super();
			LandSupply = landSupply;
			this.wta = wta;
			LandDemand = landDemand;
			this.wtp = wtp;
		}
		
		public FarmInputProperties(String landSupply, String wta, String landDemand, String wtp) {
			this(Float.parseFloat(landSupply),Float.parseFloat(wta),Float.parseFloat(landDemand),Float.parseFloat(wtp));
		}
		
		public float getLandSupply() {
			return LandSupply;
		}
		public void setLandSupply(float landSupply) {
			LandSupply = landSupply;
		}
		public float getWta() {
			return wta;
		}
		public float getLandDemand() {
			return LandDemand;
		}
		public void setLandDemand(float landDemand) {
			LandDemand = landDemand;
		}
		public float getWtp() {
			return wtp;
		}
		
		
	}
	
	private class ArrayIndexComparator implements Comparator<Integer>
	{
	    private final Double[] array;

	    public ArrayIndexComparator(Double[] array)
	    {
	        this.array = array;
	    }

	    public Integer[] createIndexArray()
	    {
	        Integer[] indexes = new Integer[array.length];
	        for (int i = 0; i < array.length; i++)
	        {
	            indexes[i] = i; // Autoboxing
	        }
	        return indexes;
	    }

	    @Override
	    public int compare(Integer index1, Integer index2)
	    {
	         // Autounbox from Integer to int to use as array indexes
	        return array[index1].compareTo(array[index2]);
	    }
	}
	
	private class participationScore  {
		
		/**
		 * 
		 */
		private static final long serialVersionUID = 1L;


		public participationScore (HashMap<String,FarmInputProperties> fp,String cmd) {
			for(String f: fp.keySet()) {
				if(cmd=="WTA") {
					Float fl = fp.get(f).getWta();
					Double d = new Double(fl.floatValue());
					this.put(f, d);
				}
				else {
					Float fl = fp.get(f).getWtp();
					Double d = new Double(fl.floatValue());
					this.put(f, d);
				}
				
			}
		}
		
		
		public void calculateScore(Double[] rnd) {
			for(String f: this.keySet()) {
				ind = this.ke
				Double val = this.get(f)*rnd[this.get(f).]
				this.put(f, value)
			}
		}
	}
	
	 
	
}




