#!/usr/bin/ruby

require 'Qt'

class BugDialog < Qt::Dialog	
	$saved_value=''
    def initialize(title, text, value)
        super()
        
        setWindowTitle title
        
        init_ui(text, value)
        
        resize 400, 100
        move 300, 300

        show
    end
    
    def init_ui(text, value)
        vbox = Qt::VBoxLayout.new self

        vbox1 = Qt::VBoxLayout.new
        hbox1 = Qt::HBoxLayout.new
        hbox2 = Qt::HBoxLayout.new

        text_label = Qt::Label.new(text, self)
        @text_edit = Qt::LineEdit.new self      
        @text_edit.setText value
       
        save_button = Qt::PushButton.new "Save", self

        vbox.addWidget text_label

        hbox1.addWidget @text_edit
        hbox1.addLayout vbox1
        vbox.addLayout hbox1

        hbox2.addStretch 1
        hbox2.addWidget save_button       
        vbox.addLayout hbox2, 1

        setLayout vbox

        connect save_button, SIGNAL('clicked()'), self, SLOT('save()')

        setWindowFlags(Qt::WindowStaysOnTopHint | Qt::CustomizeWindowHint | Qt::WindowTitleHint | Qt::Tool )
        @text_edit.setFocus
        @text_edit.selectAll

    end

    slots 'save()'

    def save()    	
    	$saved_value = @text_edit.text
    	$qApp.quit()
    	
    end

    def self.prompt_for_task(title, text, value)
    	app = Qt::Application.new ARGV
		BugDialog.new(title, text, value)
		app.exec
		$saved_value
    end

end
