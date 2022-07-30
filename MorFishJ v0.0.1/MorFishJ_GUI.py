from javax.swing import SwingWorker, JFrame, JPanel, JLabel, JButton, ImageIcon, BorderFactory
from java.awt import Dimension, Font, GridBagLayout, Color, BorderLayout, GridBagConstraints, Insets
from javax.swing.border import EtchedBorder
from ij import IJ

## MorFishJ version
version = "v0.0.1"

## Path to MorFishJ
plugin_path = IJ.getDir("plugins") + "/MorFishJ " + version + "/"

## Install macros
macros_path = plugin_path + "macros.ijm"
IJ.run("Install...", "install=[" + macros_path + "]")

## Create GUI window
frame = JFrame("MorFishJ " + version)
frame.setResizable(False)

## Panel 1 - Main Traits
panel1 = JPanel(GridBagLayout())
panel1.setBorder(
    BorderFactory.createTitledBorder(
    BorderFactory.createEtchedBorder(
        EtchedBorder.RAISED, Color.GRAY, Color.DARK_GRAY), "Main Traits"))
panel1.getBorder().setTitleFont(Font("Dialog", Font.BOLD, 15))

## Panel 2 - Head Angles
panel2 = JPanel(GridBagLayout())
panel2.setBorder(
    BorderFactory.createTitledBorder(
    BorderFactory.createEtchedBorder(
        EtchedBorder.RAISED, Color.GRAY, Color.DARK_GRAY), "Head Angles"))
panel2.getBorder().setTitleFont(Font("Dialog", Font.BOLD, 15))

## Panel 3 - Gut Traits
panel3 = JPanel(GridBagLayout())
panel3.setBorder(
    BorderFactory.createTitledBorder(
    BorderFactory.createEtchedBorder(
        EtchedBorder.RAISED, Color.GRAY, Color.DARK_GRAY), "Gut Traits"))
panel3.getBorder().setTitleFont(Font("Dialog", Font.BOLD, 15))

## Define action for each button
macro = ""

class TraitTask( SwingWorker ) :
    def doInBackground(self) :
        # Class implementing long running task as a SwingWorker thread
        try :
            IJ.run(macro)
        except :
            Type, value = sys.exc_info()[:2]
            print 'Error:', str(type)
            print 'value:', str(value)
            self.msg.setText(str(value))
            
def MT(event):
   global macro 
   macro = "Main Traits"
   TraitTask().execute()

def MTM(event):
   global macro 
   macro = "Main Traits Multi"
   TraitTask().execute()

def MTC(event):
   global macro 
   macro = "Main Traits Cont"
   TraitTask().execute()

def HA(event):
   global macro 
   macro = "Head Angles"
   TraitTask().execute()

def HAM(event):
   global macro 
   macro = "Head Angles Multi"
   TraitTask().execute()

def HAC(event):
   global macro 
   macro = "Head Angles Cont"
   TraitTask().execute()

def GT(event):
   global macro 
   macro = "Gut Traits"
   TraitTask().execute()

def GTM(event):
   global macro 
   macro = "Gut Traits Multi"
   TraitTask().execute()

def GTC(event):
   global macro 
   macro = "Gut Traits Cont"
   TraitTask().execute()

## Icons, labels, and buttons
def scaledImageIcon(path, w):
   I = ImageIcon(path)
   I = I.getImage()
   sI = I.getScaledInstance(w, -1, I.SCALE_SMOOTH)
   return ImageIcon(sI)

icon1 = scaledImageIcon(plugin_path + "Icons/FishTraitsIcon.png", 60)
icon2 = scaledImageIcon(plugin_path + "Icons/HeadAnglesIcon.png", 60)
icon3 = scaledImageIcon(plugin_path + "Icons/GutTraitsIcon.png", 60)
label1 = "<html>Main morphometric analysis to obtain a complete<br> morphological characterisation from side-view images</html>"
label2 = "Analysis of head, mouth, and eye-mouth angles"
label3 = "<html>Analysis of three intestinal traits:<br>length, diameter, and external surface area</html>"
i1 = JLabel(icon1)
b1 = JButton("Single Image", actionPerformed = MT)
b1.setFont(Font("Dialog", Font.BOLD, 15))
l1 = JLabel(label1)
l1.setFont(Font("Dialog", Font.BOLD, 15))
b2 = JButton("Multiple Images...New", actionPerformed = MTM)
b2.setFont(Font("Dialog", Font.BOLD, 15))
b3 = JButton("Continued Analysis", actionPerformed = MTC)
b3.setFont(Font("Dialog", Font.BOLD, 15))
i2 = JLabel(icon2)
l2 = JLabel(label2)
l2.setFont(Font("Dialog", Font.BOLD, 15))
b4 = JButton("Single Image", actionPerformed = HA)
b4.setFont(Font("Dialog", Font.BOLD, 15))
b5 = JButton("Multiple Images...New", actionPerformed = HAM)
b5.setFont(Font("Dialog", Font.BOLD, 15))
b6 = JButton("Continued Analysis", actionPerformed = HAC)
b6.setFont(Font("Dialog", Font.BOLD, 15))
i3 = JLabel(icon3)
l3 = JLabel(label3)
l3.setFont(Font("Dialog", Font.BOLD, 15))
b7 = JButton("Single Image", actionPerformed = GT)
b7.setFont(Font("Dialog", Font.BOLD, 15))
b8 = JButton("Multiple Images...New", actionPerformed = GTM)
b8.setFont(Font("Dialog", Font.BOLD, 15))
b9 = JButton("Continued Analysis", actionPerformed = GTC)
b9.setFont(Font("Dialog", Font.BOLD, 15))

## Define position of icons and buttons - same for all panels
a = GridBagConstraints()
a.gridx = 0   
a.gridy = 0
a.gridwidth = 1
a.weightx = 0.2
a.insets = Insets(10, 10, 10, 10)
a.fill = GridBagConstraints.HORIZONTAL

b = GridBagConstraints()
b.gridx = 1   
b.gridy = 0
b.gridwidth = 2
b.weightx = 0.8
b.insets = Insets(10, 10, 10, 10)
b.fill = GridBagConstraints.HORIZONTAL

c = GridBagConstraints()
c.gridx = 0   
c.gridy = 1
c.gridwidth = 1
c.weightx = 0.5
c.insets = Insets(10, 10, 10, 10)
c.fill = GridBagConstraints.HORIZONTAL

d = GridBagConstraints()
d.gridx = 1   
d.gridy = 1
d.gridwidth = 1
d.weightx = 0.5
d.insets = Insets(10, 10, 10, 10)
d.fill = GridBagConstraints.HORIZONTAL

e = GridBagConstraints()
e.gridx = 2  
e.gridy = 1
e.gridwidth = 1
e.weightx = 0.5
e.insets = Insets(10, 10, 10, 10)
e.fill = GridBagConstraints.HORIZONTAL

## Add icons, labels, and buttons to panels
panel1.add(i1, a)
panel1.add(l1, b)
panel1.add(b1, c)
panel1.add(b2, d)
panel1.add(b3, e)

panel2.add(i2, a)
panel2.add(l2, b)
panel2.add(b4, c)
panel2.add(b5, d)
panel2.add(b6, e)

panel3.add(i3, a)
panel3.add(l3, b)
panel3.add(b7, c)
panel3.add(b8, d)
panel3.add(b9, e)

## Add panels to GUI window
frame.add(panel1, BorderLayout.PAGE_START)
frame.add(panel2, BorderLayout.CENTER)
frame.add(panel3, BorderLayout.PAGE_END)
frame.pack()
frame.setVisible(True)
