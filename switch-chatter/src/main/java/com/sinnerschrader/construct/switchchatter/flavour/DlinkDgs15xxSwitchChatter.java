package com.sinnerschrader.construct.switchchatter.flavour;

import java.io.PrintWriter;

import com.sinnerschrader.construct.switchchatter.SwitchChatter;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.ConfigureTerminal;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.DlinkPasswordPrompt;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.Enable;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.Exit;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.HpSetupTerminal;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.ShowRunningConfig;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.WaitForPrompt;
import com.sinnerschrader.construct.switchchatter.steps.flavoured.Yes;
import com.sinnerschrader.construct.switchchatter.steps.generic.CollectOutputStep;
import com.sinnerschrader.construct.switchchatter.steps.generic.CommandStep;
import com.sinnerschrader.construct.switchchatter.steps.generic.WaitForStep;

public class DlinkDgs15xxSwitchChatter extends SwitchChatter {

	public void skipSplashScreen() {
		// no splash screen exists
	}

	@Override
	protected void enterManagementMode(String password) {
		getOutputConsumer().addStep(new Enable());
		getOutputConsumer().addStep(new DlinkPasswordPrompt());
		getOutputConsumer().addStep(new CommandStep() {
			@Override
			public int performStep(StringBuffer inputBuffer,
					PrintWriter terminalWriter) {
				terminalWriter.println(password);
				return 0;
			}
		});

	}

	public void setupTerminal() {
//		getOutputConsumer().addStep(new HpSetupTerminal());
//		getOutputConsumer().addStep(new WaitForPrompt());
	}

	public void applyConfig(String config) {
//		getOutputConsumer().addStep(new ConfigureTerminal());
//		getOutputConsumer().addStep(new WaitForPrompt());
//
//		String[] lines = config.split("\\n");
//		for (int i = 0; i < lines.length; i++) {
//			final String line = lines[i];
//			getOutputConsumer().addStep(new CommandStep() {
//				@Override
//				public int performStep(StringBuffer input, PrintWriter pw) {
//					pw.println(line);
//					System.out.println("Applying config: " + line);
//					return 0;
//				}
//			});
//			getOutputConsumer().addStep(new CollectOutputStep("#"));
//		}
//
//		getOutputConsumer().addStep(new Exit());
	}

	public void retrieveConfig() {
//		getOutputConsumer().addStep(new ShowRunningConfig());
//
//		getOutputConsumer().addStep(
//				new WaitForStep("Running configuration:\n\r") {
//					@Override
//					public int performStep(StringBuffer input, PrintWriter pw) {
//						return getConsumedTill();
//					}
//				});
//
//		getOutputConsumer().addStep(new CollectOutputStep("" + (char) 27));
	}

	public void exit() {
//		getOutputConsumer().addStep(new Exit());
//		getOutputConsumer().addStep(new Exit());
//		getOutputConsumer().addStep(new Yes());
	}

}
