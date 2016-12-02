package gr.kremmydas.cloningExperiment.landmarket;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
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
	
	private int numOfFarms;
	private FarmInputProperties[] farmInput;
	private FarmOutputProperties[] farmOutput;
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
		try {
			m.numOfFarms = countLines(args[0]);
		} catch (IOException e) {
			e.printStackTrace();
		}
		m.readInput(args[0]);
		
		m.clearMarket();		
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
	
	
	private void clearMarket() {
		
		ArrayList<Integer> sellers = new ArrayList<>();
		ArrayList<Integer> buyers = new ArrayList<>();
		
		//construct sellers-buyers list
		for(int f=0;f<this.numOfFarms;f++) {
			if(this.farmInput[f].LandSupply>0) {sellers.add(f);}
			if(this.farmInput[f].LandDemand>0) {buyers.add(f);}
		}
		
		System.out.println("-- NumOfSellers:"+sellers.size() + "  NumOfBuyers:"+buyers.size());
		
		//get sellers score
		int sellers_size=sellers.size();
		double[] sellers_score = new double[sellers_size];
		for(int s=0;s<sellers_size;s++) {
			sellers_score[s]=this.rnd.get(this.curRndIndex)*this.farmInput[sellers.get(s)].getWta();
			this.curRndIndex++;
		}
		//get sorted sellers by score
		ArrayIndexComparator sellersComparator = new ArrayIndexComparator(sellers_score);
		Integer[] sellers_indexes = sellersComparator.createIndexArray();
		Arrays.sort(sellers_indexes, sellersComparator);
		
		
		//get buyers score
		int buyers_size=sellers.size();
		double[] buyers_score = new double[buyers_size];
		for(int s=0;s<buyers_size;s++) {
			buyers_score[s]=this.rnd.get(this.curRndIndex)*this.farmInput[buyers.get(s)].getWtp();
			this.curRndIndex++;
		}
		//get sorted buyers by score
		ArrayIndexComparator buyersComparator = new ArrayIndexComparator(buyers_score);
		Integer[] buyers_indexes = buyersComparator.createIndexArray();
		Arrays.sort(buyers_indexes, buyersComparator);
		
		
		if(this.loops>buyers_size) this.loops=buyers_size;
		if(this.loops>sellers_size) this.loops=sellers_size;
			
		for(int i=0;i<this.loops;i++) {
			
			this.logResult+=System.getProperty("line.separator")+String.valueOf(i)+"\t";
			
			//System.out.println();System.out.println("Loop:"+i);
			
			//select the next pair
			int bf = buyers.get(buyers_indexes[i]); 
			int sf = sellers.get(sellers_indexes[i]);
			
			this.logResult+=bf+"\t"+this.farmInput[bf].getWtp()+"\t";
			this.logResult+=sf+"\t"+this.farmInput[sf].getWta()+"\t";
			
			if(sf==bf) {continue;}
			
			//System.out.println("Bf:"+bf+ " wtp:"+farmInput.get(bf).getWtp()+ " / Sf:"+sf+" wta:"+farmInput.get(sf).getWta());
			
			//if buyer-WTP>seller-WTA get a random price between and make the transaction
			if(farmInput[bf].getWtp()>farmInput[sf].getWta()) {
				//transaction means to update farmOutput and adjust farmInput and sellers/buyers list
				float landTrans = (farmInput[bf].getLandDemand()<farmInput[sf].getLandSupply())?farmInput[bf].getLandDemand():farmInput[sf].getLandSupply();
				float price = farmInput[bf].getWtp()-(farmInput[bf].getWtp()-farmInput[sf].getWta())*(new Random().nextFloat());

				this.logResult+=landTrans+"\t"+price+"\t"+(landTrans*price);
				
				//update demand supply
				farmInput[bf].setLandDemand(farmInput[bf].getLandDemand()-landTrans);
				farmInput[sf].setLandSupply(farmInput[sf].getLandSupply()-landTrans);
						
				//update cash
				farmOutput[bf].setCash(-1*(landTrans*price));
				farmOutput[bf].setRentedIn(landTrans);
				
				farmOutput[sf].setCash(landTrans*price);
				farmOutput[sf].setRentedOut(landTrans);
			}
			else {
				this.logResult+="NA\tNA\tNA";
			}			
		}
		
	}
	
	private void writeOutput(String outFile) {
		String r = "";
		for(int f=0;f<this.numOfFarms;f++) {
			FarmOutputProperties fop = this.farmOutput[f];
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
		this.farmInput = new FarmInputProperties[this.numOfFarms];
		this.farmOutput = new FarmOutputProperties[this.numOfFarms];
		Scanner sc = null;
		try {
			sc = new Scanner(new FileReader(inFile));
			sc.useDelimiter(System.getProperty("line.separator"));
			
			String[] split=new String[5];
			int count=0;
		    while (sc.hasNext()){
		    	String line=sc.next();	    	
		    	split = line.split("\\t");
		        farmInput[count]= new FarmInputProperties(split[1], split[2], split[3], split[4]);
		        farmOutput[count]= new FarmOutputProperties(0,0,0);
		        count++;
		    }
		    
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		
		
	}
	
	private static int countLines(String filename) throws IOException {
	    InputStream is = new BufferedInputStream(new FileInputStream(filename));
	    try {
	        byte[] c = new byte[1024];
	        int count = 0;
	        int readChars = 0;
	        boolean empty = true;
	        while ((readChars = is.read(c)) != -1) {
	            empty = false;
	            for (int i = 0; i < readChars; ++i) {
	                if (c[i] == '\n') {
	                    ++count;
	                }
	            }
	        }
	        return (count == 0 && !empty) ? 1 : count;
	    } finally {
	        is.close();
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
	    private final double[] array;

	    public ArrayIndexComparator(double[] array)
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
	    	return Double.compare(array[index1], array[index2]);
	    }
	}
	
	
	
	 
	
}




