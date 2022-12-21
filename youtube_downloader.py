from tkinter import *
from pytube import YouTube

# Create a window
window = Tk()
window.title("Youtube Downloader")
window.geometry("480x36")

# Create a label
label = Label(window, text="Paste the link")
label.grid(column=0, row=0)

# Create a text box
textbox = Entry(window, width=20)
textbox.grid(column=1, row=0)
# https://youtu.be/xBpX0O6n9ZY


def on_click():
    label.configure(text="Downloading... ")
    YouTube(str(textbox.get())).streams.first().download()
    label.configure(text="Download complete ")


# Create a button
button = Button(window, text="Download", command=on_click)
button.grid(column=2, row=0)

window.mainloop()
