package ui;

import lysis.Lysis;

import java.util.Scanner;

import javax.swing.JFrame;
import javax.swing.JTextArea;
import javax.swing.JButton;
import javax.swing.JScrollPane;
import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JFileChooser;
import javax.swing.Box;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.awt.Font;
import java.awt.Color;
import java.awt.Toolkit;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.datatransfer.StringSelection;

import java.io.File;
import java.io.PrintWriter;
import java.io.FileOutputStream;
import java.io.FileInputStream;

public class LysisUI extends JFrame
{
    /* Window Settings */
    public static final int WINDOW_WIDTH = 850;
    public static final int WINDOW_HEIGHT = 550;

    /* Instance Variables */
    JTextArea output;
    String path;
    boolean decompiled;

    public LysisUI()
    {
        super("Lysis Decompiler");

        this.path = null;
        this.decompiled = false;

        /* Window Settings */
        this.setSize(WINDOW_WIDTH, WINDOW_HEIGHT);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        /* North Panel */
        JPanel north = new JPanel();
        north.setLayout(new FlowLayout());
        north.setBackground(Color.gray);

        JLabel title = new JLabel("Lysis Decompiler");
        Font font = new Font("Atlantic Cruise", Font.BOLD, 13);
        title.setFont(font);
        title.setForeground(Color.white);
        north.add(title);

        /* West Panel */
        JPanel west = new JPanel();
        west.setLayout(new FlowLayout());
        west.setPreferredSize(new Dimension(120, 400));
        west.setBackground(Color.gray);

        JButton loadFile = new JButton("Load File");
        loadFile.setPreferredSize(new Dimension(120, 27));
        loadFile.addActionListener(new LoadFileListener());

        JButton saveFile = new JButton("Save File");
        saveFile.setPreferredSize(new Dimension(120, 27));
        saveFile.addActionListener(new SaveButtonListener());

        JButton copyText = new JButton("Copy All");
        copyText.setPreferredSize(new Dimension(120, 27));
        copyText.addActionListener(new CopyButtonListener());

        JButton decompile = new JButton("Decompile!");
        decompile.setPreferredSize(new Dimension(120, 27));
        decompile.addActionListener(new DecompileButtonListener());

        west.add(Box.createRigidArea(new Dimension(120, 10)));
        west.add(loadFile);
        west.add(Box.createRigidArea(new Dimension(120, 10)));
        west.add(saveFile);
        west.add(Box.createRigidArea(new Dimension(120, 10)));
        west.add(copyText);
        west.add(Box.createRigidArea(new Dimension(120, 10)));
        west.add(decompile);

        /* Center panel */
        output = new JTextArea();
        output.setEditable(false);
        output.setBackground(Color.black);
        output.setFont(new Font("Consolas", Font.PLAIN, 12));
        output.setForeground(Color.white);

        /* Add panels to frame */
        this.add(north, BorderLayout.NORTH);
        this.add(west, BorderLayout.WEST);
        this.add(new JScrollPane(output), BorderLayout.CENTER);

        this.setVisible(true);
        this.setResizable(true);
        this.setLocationRelativeTo(null);
    }

    private class SaveButtonListener implements ActionListener
    {
        @Override
        public void actionPerformed(ActionEvent e)
        {
            if (!decompiled)
            {
                JOptionPane.showMessageDialog(LysisUI.this, "You must first decompile before you save!", "Error!", JOptionPane.ERROR_MESSAGE);
                return;
            }

            JFileChooser f = new JFileChooser();
            f.setFileSelectionMode(JFileChooser.FILES_ONLY);
            f.setDialogTitle("Select A Folder To Save");
            f.setSelectedFile(new File("output.txt"));
            f.setFileFilter(new FileNameExtensionFilter("Text File (*.txt)", "txt"));
            int result = f.showSaveDialog(LysisUI.this);

            if (result != f.APPROVE_OPTION)
            {
                return; // User canceled saving the file
            }

            File file = f.getSelectedFile();

            try
            {
                PrintWriter writer = new PrintWriter(new FileOutputStream(file.toString(), false));

                String[] data = LysisUI.this.output.getText().split("\\r?\\n");

                for (String item : data)
                {
                    writer.println(item);
                }
                writer.close();
            }
            catch (Exception ex)
            {
                JOptionPane.showMessageDialog(LysisUI.this, "Error writing to file!", "Error!", JOptionPane.ERROR_MESSAGE);
                return;
            }
        }
    }

    private class LoadFileListener implements ActionListener
    {
        @Override
        public void actionPerformed(ActionEvent e)
        {
            JFileChooser f = new JFileChooser();
            FileNameExtensionFilter filter = new FileNameExtensionFilter("smx or amxx files (*.smx or *.amxx)", "smx", "amxx");
            f.setFileSelectionMode(JFileChooser.FILES_ONLY);
            f.setDialogTitle("Select a file to open");
            f.setFileFilter(filter);
            f.showOpenDialog(LysisUI.this);

            File file = f.getSelectedFile();
            if (file == null)
            {
                return; // User canceled saving the file
            }

            LysisUI.this.path = f.getSelectedFile().toString();
            LysisUI.this.output.append("< File selected! >");
        }
    }

    private class CopyButtonListener implements ActionListener
    {
        public void actionPerformed(ActionEvent e)
        {
            if (!decompiled)
            {
                JOptionPane.showMessageDialog(LysisUI.this, "You must first decompile before you copy!", "Error!", JOptionPane.ERROR_MESSAGE);
                return;
            }

            Toolkit.getDefaultToolkit().getSystemClipboard().setContents(new StringSelection(output.getText()), null);
            JOptionPane.showMessageDialog(LysisUI.this, "Copied Successfully!", "Text Copied!", JOptionPane.INFORMATION_MESSAGE);
        }
    }

    private class DecompileButtonListener implements ActionListener
    {
        public void actionPerformed(ActionEvent e)
        {
            if (LysisUI.this.path == null)
            {
                JOptionPane.showMessageDialog(LysisUI.this, "Error: No file selected!", "Error!", JOptionPane.ERROR_MESSAGE);
                return;
            }

            try
            {
                LysisUI.this.output.setText(""); // clear

                File output = File.createTempFile("output", ".tmp");
                FileOutputStream outStream = new FileOutputStream(output);
                File errors = File.createTempFile("errors", ".tmp");
                FileOutputStream errStream = new FileOutputStream(errors);

                Lysis.decompile(outStream, errStream, LysisUI.this.path);

                outStream.close();
                errStream.close();

                Scanner reader = new Scanner(new FileInputStream(output));
                String line;
                while(reader.hasNextLine())
                {
                    line = reader.nextLine();
                    LysisUI.this.output.append(line + "\n");
                }
                reader.close();

                reader = new Scanner(new FileInputStream(errors));
                while(reader.hasNextLine())
                {
                    line = reader.nextLine();
                    LysisUI.this.output.append(line + "\n");
                }
                reader.close();

                output.delete();
                errors.delete();
                decompiled = true;
            }
            catch (Exception ex)
            {
                JOptionPane.showMessageDialog(LysisUI.this, "Error! Decompilation failed", "Error!", JOptionPane.ERROR_MESSAGE);
                return;
            }

            JOptionPane.showMessageDialog(LysisUI.this, "Decompilation successful!", "Alert!", JOptionPane.INFORMATION_MESSAGE);
            return;
        }
    }

    public static void main(String[] args)
    {
        new LysisUI();
    }
}