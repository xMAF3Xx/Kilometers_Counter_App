import SwiftUI

struct Viaggio: Identifiable, Equatable {
    let id = UUID()
    let nome: String
    let km: String
    let data: String
}

struct CentralView: View {
    @State private var righe: [String] = []
    @State private var showingPopup = false
    @State private var newName = ""
    @State private var numeroSelezionato = 0
    var file: URL {
        documentsFile("kilometers_list.csv")
    }
    @State private var selectedDate = Date()
    @State private var nameList = [String]()
    @State private var dateList = [String]()
    //@State private var kmList = [Int]()
    @Binding var kmList: [Int]
    @State private var viaggioSelezionato: Viaggio?
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
    
    var body: some View {
        //SettingsScreen(kmListed: $kmList)
        ZStack {
            VStack {
                if righe.isEmpty {
                    Text("Aggiungi dei Viaggi!")
                } else {
                    NavigationView {
                        List {
                            ForEach(righe, id: \.self) { riga in
                                SwiftUICore.HStack {
                                    Text(riga.components(separatedBy: ";")[1])
                                    Spacer()
                                    Button {
                                        let comps = riga.components(separatedBy: ";")
                                        if comps.count >= 3 {
                                            viaggioSelezionato = Viaggio(
                                                nome: comps[1],
                                                km: comps[0],
                                                data: comps[2]
                                            )
                                        }
                                    } label: {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let index = righe.firstIndex(of: riga) {
                                            righe.remove(at: index)
                                            rimuoviRigaDaFile(indiceRiga: index)
                                            loadArrays()
                                        }
                                    } label: {
                                        Label("Cancella", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .navigationTitle("Viaggi")
                        .sheet(item: $viaggioSelezionato) { viaggio in
                            VStack {
                                HStack{
                                    Button {
                                        viaggioSelezionato = nil
                                    } label: {
                                        Image(systemName: "xmark")
                                            .padding()
                                            .background(Color.red)
                                            .foregroundColor(.white)
                                            .cornerRadius(30)
                                            .padding()
                                    }
                                    Text("\t\(viaggio.nome)")
                                        .font(.title)
                                    Spacer()
                                }
                                Text("kilometri percorsi: \(viaggio.km)km")
                                Text("Data: \(viaggio.data)")
                                Spacer()
                            }
                            .padding()
                        }
                    }
                    .onAppear(){
                        loadArrays()
                    }
                }
            }
            HStack {
                Spacer()
                Button {
                    showingPopup = true
                } label: {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding()
                .sheet(isPresented: $showingPopup) {
                    popupSalvataggio
                }
            }
        }
        .onAppear {
            caricaCSV()
        }
    }
    
    var popupSalvataggio: some View {
        VStack {
            HStack {
                Button {
                    showingPopup = false
                } label: {
                    Image(systemName: "xmark")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .padding()
                }
                Text("\tDati Viaggio")
                    .font(.largeTitle)
                Spacer()
            }
            
            HStack {
                Text("Kilometri:")
                Picker("Seleziona", selection: $numeroSelezionato) {
                    ForEach(1..<301, id: \.self) { numero in
                        Text("\(numero)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 85)
            }
            .padding()
            
            HStack {
                Text("Nome Viaggio:")
                TextField("inserire nome...", text: $newName)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            .padding()
            Spacer()
                Section(header: Text("Seleziona una data:")) {
                    DatePicker("",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
            Spacer()
            
            HStack {
                Spacer()
                Button("Salva") {
                    salvaCSV()
                    showingPopup = false
                    caricaCSV()
                    loadArrays()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(30)
                .padding()
            }
            .padding()
        }
    }
    
    func caricaCSV() {
        if !FileManager.default.fileExists(atPath: file.path) {
            righe = []
            return
        }
        do {
            let content = try String(contentsOf: file, encoding: .utf8)
            righe = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } catch {
            righe = ["Errore nella lettura del file"]
        }
    }
    
    func salvaCSV() {
        let dataString = dateFormatter.string(from: selectedDate)
        let nuovaRiga = "\(numeroSelezionato);\(newName);\(dataString)\n"
        
        if !FileManager.default.fileExists(atPath: file.path) {
            try? nuovaRiga.write(to: file, atomically: true, encoding: .utf8)
        } else {
            if let handle = try? FileHandle(forWritingTo: file) {
                handle.seekToEndOfFile()
                handle.write(nuovaRiga.data(using: .utf8)!)
                try? handle.close()
            }
        }
        
        caricaCSV()
    }

    
    func documentsFile(_ name: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
    }
    
    func loadArrays() {
        kmList.removeAll()
        nameList.removeAll()
        dateList.removeAll()
        
        for riga in righe {
            let parti = riga.components(separatedBy: ";")
            if parti.count >= 3 {
                if let km = Int(parti[0]) {
                    kmList.append(km)
                }
                nameList.append(parti[1])
                dateList.append(parti[2])
            }
        }
    }


    func rimuoviRigaDaFile(indiceRiga: Int) {
        do {
            let contenuto = try String(contentsOf: file, encoding: .utf8)
            var righe = contenuto.components(separatedBy: .newlines)
            
            guard indiceRiga >= 0 && indiceRiga < righe.count else {
                print("Indice riga fuori dai limiti")
                return
            }
            
            righe.remove(at: indiceRiga)
            
            let nuovoContenuto = righe.joined(separator: "\n")
            try nuovoContenuto.write(to: file, atomically: true, encoding: .utf8)
            
            print("Riga \(indiceRiga) rimossa con successo!")
        } catch {
            print("Errore nella lettura o scrittura del file: \(error)")
        }
    }
}

#Preview{
    CentralView(kmList: .constant([10, 20, 30]))
}

