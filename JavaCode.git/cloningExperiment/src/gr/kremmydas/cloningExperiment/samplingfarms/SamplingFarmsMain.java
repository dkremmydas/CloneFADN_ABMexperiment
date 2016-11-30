package gr.kremmydas.cloningExperiment.samplingfarms;
import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.Random;

public class SamplingFarmsMain {
	
	private int totalFarms;
	private int sampledFarms;
	private int[] clonedPopulation;

	/**
	 * 
	 * @param args [0]=>total number of farms (after cloning) / [1]=>number of farms to sample /[2]=>file to write
	 *
	 */
	public static void main(String[] args) {
		SamplingFarmsMain sf = new SamplingFarmsMain();
		sf.totalFarms = Integer.parseInt(args[0]);
		sf.sampledFarms = Integer.parseInt(args[1]);
		
		System.out.println("totalFarms:"+sf.totalFarms);
		System.out.println("sampledFarms:"+sf.sampledFarms);
		
		sf.clonedPopulation = new int[sf.totalFarms];
		
		sf.doClone();
		sf.writeFile(args[2]);

	}
	
	private void doClone() {
		int[] realFarms = new int[this.totalFarms];
		for(int i=0;i<this.totalFarms;i++) {
			realFarms[i]=i+1;
		}
		
		this.shuffleArray(realFarms);
		
		int cloneCoef = this.totalFarms/this.sampledFarms;
		System.out.println("CloneCoefficient:"+cloneCoef);
		
		int counter=1; int counter2=0;
		do {
			this.clonedPopulation[counter-1]=realFarms[counter2];
			if(counter%cloneCoef==0) {counter2++;}
			counter++;
			
		} while(counter<=this.totalFarms);
		
		
		
		
	}
	
	private void writeFile(String outFile) {
		String r = "";String sep="";
		for(int i=0;i<this.totalFarms;i++) {
			r += sep + "f"+(i+1) + "." + "f"+this.clonedPopulation[i];
			sep=",";
		}
	
		try (Writer writer = new BufferedWriter(new OutputStreamWriter(
	              new FileOutputStream(outFile), "utf-8"))) {
		   writer.write(r);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	private void shuffleArray(int[] array)
	{
	    int index;
	    Random random = new Random();
	    for (int i = array.length - 1; i > 0; i--)
	    {
	        index = random.nextInt(i + 1);
	        if (index != i)
	        {
	            array[index] ^= array[i];
	            array[i] ^= array[index];
	            array[index] ^= array[i];
	        }
	    }
	}

}
