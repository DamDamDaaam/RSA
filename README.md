# RSA

            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            ~~ Implementazione di un encrypter-decrypter RSA ~~
            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Interfaccia utente:

    ~ Slide Switches:
        
        - SW[3:2]           Mode selection           (Output su SevenSegment)
            00      -->     Spento                   (-)
            01      -->     Generazione chiave       (S. = Searching,           n. = chiave n,              d. = chiave d,      E. = chiave e)
            11      -->     Criptaggio               (n. = inserire chiave n,   E. = inserire chiave e,     C. = Crypting)
            10      -->     Decriptaggio             (n. = inserire chiave n,   d. = inserire chiave d,     U. = Uncrypting)

        - SW[1] : OutputEnable (0 -> tutte le cifre del SevenSegment a "-",    1 -> visualizza valore)
        
        - SW[0] : KeySelection (seleziona la chiave da inserire/visualizzare:  0 -> n, 1 -> d)
        
    ~ Buttons:
        - BTN[3]: Delete
        - BTN[2]: Start
        - BTN[1]: DigitSelection
        - BTN[0]: DigitIncrement
        
    ~ SevenSegment  :   Mode. - chiave(n, d, e)
    
    ~ UART          :   IN -> messaggi da crittare/decrittare   OUT -> messaggi crittati/decrittati

Descrizione delle mode:
    
    ~ Spento (SW[3:2] = 00) ~
        Quando si portano gli interruttori in questa posizione viene diramato a tutto il sistema un RESET GLOBALE
    
    ~ Generazione chiavi (SW[3:2] = 01) ~
        In questa mode si può generare un set di tre chiavi (n_key, e_key e d_key) valide per l'RSA encoding:
        - per avviare la generazione premere Start
        - per resettare il KeyGenerator premere Delete
        A generazione avvenuta sul display sarà possibile visualizzare le tre chiavi:
        - KeySelection = 0                          ->       n_key 
        - KeySelection = 1, DigitSelection = 0      ->       e_key 
        - KeySelection = 1, DigitSelection = 1      ->       d_key 
    
    ~ Criptaggio (SW[3:2] = 11) ~
        In questa mode si possono usare le chiavi generate dal KeyGenerator per criptare un messaggio trasmesso tramite UART:
        - per avviare la traduzione premere Start
        - per interrompere la traduzione premere Delete (?)
        Prima di avviare la traduzione è possibile visualizzare le chiavi che verranno utilizzate:
        - KeySelection = 0          ->       n_key 
        - KeySelection = 1          ->       e_key
        Premendo Delete mentre è visualizzata una chiave è possibile immettere un valore da usare al posto di quello generato:
        - premere DigitSelection consente di selezionare la cifra da modificare (quella selezionata è indicata dal lampeggiare del punto decimale)
        - premere DigitIncrement aggiunge 1 alla cifra selezionata (se si raggiunge il valore massimo si ricomincia da 0)
        Una volta inserito il valore della cifra più significativa premere un'ultima volta DigitSelection per confermare il valore.
        Se si preme Delete durante la scrittura la chiave selezionata viene posta al valore 0.
        
    ~ Decriptaggio (SW[3:2] = 10) ~
        In questa mode si possono usare le chiavi generate dal KeyGenerator per decriptare un messaggio trasmesso tramite UART:
        - per avviare la traduzione premere Start
        - per interrompere la traduzione premere Delete (?)
        Prima di avviare la traduzione è possibile visualizzare le chiavi che verranno utilizzate:
        - KeySelection = 0          ->       n_key 
        - KeySelection = 1          ->       d_key
        Premendo Delete mentre è visualizzata una chiave è possibile immettere un valore da usare al posto di quello generato:
        - premere DigitSelection consente di selezionare la cifra da modificare (quella selezionata è indicata dal lampeggiare del punto decimale)
        - premere DigitIncrement aggiunge 1 alla cifra selezionata (se si raggiunge il valore massimo si ricomincia da 0)
        Una volta inserito il valore della cifra più significativa premere un'ultima volta DigitSelection per confermare il valore.
        Se si preme Delete durante la scrittura la chiave selezionata viene posta al valore 0.

