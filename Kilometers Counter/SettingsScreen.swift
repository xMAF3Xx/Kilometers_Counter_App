import SwiftUI

struct SettingsScreen: View {
    @Binding var kmListed: [Int]
    @State private var totKm: Int
    @AppStorage("prezzo") private var prezzo: String = ""
    @AppStorage("totale") private var totale: Double = 0
    
    init(kmListed: Binding<[Int]>) {
        self._kmListed = kmListed
        self._totKm = State(initialValue: kmListed.wrappedValue.reduce(0, +))
    }
    
    var body: some View {
        VStack {
            Text("Totale Kilometri: \(totKm)km")
            HStack{
                Text("Prezzo per Kilometro: ")
                TextField("euro ",text: $prezzo)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                Text("€")
            }
            .onChange(of: prezzo) { newValue in
                if let numero = Double(prezzo) {
                    totale=Double(totKm)*numero
                } else {
                    totale = -1
                }
                totale = (totale * 100).rounded() / 100
            }
            Text("Costo Totale: "+String(totale)+"€")
            }
            .onChange(of: kmListed) { newValue in
                totKm = newValue.reduce(0, +)
            }
        }
    }
    
func sommaArray(_ numeri: [Int]) -> Int {
    numeri.reduce(0, +)
}

#Preview {
    SettingsScreen(kmListed: .constant([10, 20, 30]))
}
