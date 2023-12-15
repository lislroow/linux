package smpl.listener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class SmplServletContextListener implements ServletContextListener {

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		
	}
	
	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		for (int i=0; i<=10; i++) {
			System.out.println("[countdown] " + (10-i));
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	
}
