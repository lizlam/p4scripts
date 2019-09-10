import java.awt.Desktop;
import java.io.IOException;
import java.net.URI;
 
/**
 * Quick and dirty P4V Custom Tool to view file content in Swarm.
 *
 * In P4V, click on Tools -> Manage Custom Tools...
 * Click on New -> Tool...
 * In Add Tool dialog, enter:
 *      Name: View in Swarm
 *      Application: /path/to/java
 *      Arguments: -cp /path/to/classfile SwarmCustomTool %D
 */
public class SwarmCustomTool {
	
	static String SWARM_URL = "http://swarm.workshop.perforce.com";
	static String urls;
	
	public static void main(String[] args) {
		
		for (String s : args) {
			String file = s.substring(1);
			if (file.endsWith("...")){
				file = file.substring(0, file.length()-3);
			}
			if (urls == null) {
				urls = SWARM_URL + file; 
			} else {
				urls = urls + " " + SWARM_URL + file;	
			}
		}
		if (urls == null) {
			urls = SWARM_URL;
		}
	    try {
			Desktop.getDesktop().browse(URI.create(urls));
		} catch (IOException e) {
			e.printStackTrace();
		}	
	}
 
}
