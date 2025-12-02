import Image from 'next/image';
import Link from 'next/link';
import { 
  ArrowLeft, 
  Smartphone, 
  ScanLine, 
  Zap, 
  Camera, 
  CheckCircle2, 
  ChevronRight 
} from 'lucide-react';

export default function CardapioDemonstrativo() {
  return (
    <div className="font-sans antialiased bg-white selection:bg-[#C5A47E] selection:text-white">
      <nav className="fixed w-full z-50 bg-[#510006]/95 backdrop-blur-sm border-b border-white/10">
        <div className="container mx-auto px-8 py-4 flex justify-between items-center">
          <Link href="/" className="flex items-center gap-3 group">
            <Image
              src="/logo.svg"
              alt="Logo Techbistro"
              width={30}
              height={30}
              className="filter brightness-0 invert"
            />
            <span className="text-white font-bold tracking-[0.2em] uppercase text-sm group-hover:text-[#C5A47E] transition-colors">Techbistro</span>
          </Link>
          <div className="flex items-center gap-6">
             <Link href="/" className="flex items-center text-[10px] font-bold text-white hover:text-[#C5A47E] uppercase tracking-widest transition-colors">
                <ArrowLeft className="w-4 h-4 mr-2" /> Voltar
             </Link>
          </div>
        </div>
      </nav>

      <header className="relative pt-32 pb-24 bg-[#510006] overflow-hidden">
        <div className="absolute top-0 right-0 w-full md:w-2/3 h-full bg-gradient-to-l from-black/40 to-transparent"></div>
        <div className="container mx-auto px-8 relative z-10">
          <div className="flex flex-col md:flex-row items-center gap-16">
            <div className="w-full md:w-1/2 text-white">
              <div className="inline-flex items-center gap-2 px-3 py-1 border border-[#C5A47E]/30 rounded-full mb-8">
                <span className="w-1.5 h-1.5 rounded-full bg-[#C5A47E] animate-pulse"></span>
                <span className="text-[10px] uppercase tracking-widest text-[#C5A47E] font-bold">Funcionalidade Premium</span>
              </div>
              <h1 className="text-4xl md:text-6xl font-bold mb-8 leading-tight">
                Cardápio Digital <br/>
                <span className="text-[#C5A47E]">Inteligente</span>
              </h1>
              <p className="text-gray-300 text-sm leading-loose mb-10 max-w-lg font-light">
                Esqueça os PDFs estáticos. Apresentamos uma interface viva, onde seus pratos ganham destaque e os pedidos fluem diretamente da mesa para a cozinha, sem intermediários e sem erros.
              </p>
              <div className="flex gap-4">
                <Link href="/#planos" className="px-8 py-4 bg-[#C5A47E] text-white text-xs font-bold uppercase tracking-widest hover:bg-white hover:text-[#510006] transition-all rounded-sm shadow-lg">
                  Quero Contratar
                </Link>
              </div>
            </div>
            
            <div className="w-full md:w-1/2 flex justify-center">
               <div className="relative">
                  <div className="absolute -inset-4 bg-[#C5A47E]/20 blur-xl rounded-full"></div>
                  <div className="relative bg-black rounded-[3rem] border-4 border-gray-800 p-2 shadow-2xl w-[280px]">
                     <div className="bg-white rounded-[2.5rem] overflow-hidden h-[550px] relative">
                        <Image 
                           src="/images/mobile.jpeg" 
                           alt="Preview do App TechBistro"
                           fill
                           className="object-cover"
                        />
                     </div>
                  </div>
               </div>
            </div>
          </div>
        </div>
      </header>

      <section className="py-24 bg-white">
        <div className="container mx-auto px-8">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
            <div className="group">
              <ScanLine className="w-10 h-10 text-[#510006] mb-6 group-hover:text-[#510006] transition-colors text-gray-900" />
              <h3 className="text-sm font-bold uppercase tracking-widest mb-3">QR Code Instantâneo</h3>
              <p className="text-gray-600 text-xs leading-relaxed">
                Cada mesa possui um código único. O cliente escaneia e o sistema já identifica onde entregar o pedido.
              </p>
            </div>
            <div className="group">
              <Camera className="w-10 h-10 text-[#510006] mb-6 group-hover:text-[#C5A51000647E] transition-colors" />
              <h3 className="text-sm font-bold uppercase tracking-widest mb-3">Visual Imersivo</h3>
              <p className="text-gray-600 text-xs leading-relaxed">
                Fotos em alta definição que despertam o desejo e aumentam o ticket médio por pedido.
              </p>
            </div>
            <div className="group">
              <Zap className="w-10 h-10 text-[#510006] mb-6 group-hover:text-[#510006] transition-colors" />
              <h3 className="text-sm font-bold uppercase tracking-widest mb-3">Cozinha Sincronizada</h3>
              <p className="text-gray-600 text-xs leading-relaxed">
                O pedido sai do celular do cliente e aparece na tela da cozinha em milissegundos.
              </p>
            </div>
            <div className="group">
              <CheckCircle2 className="w-10 h-10 text-[#510006] mb-6 group-hover:text-[#510006] transition-colors" />
              <h3 className="text-sm font-bold uppercase tracking-widest mb-3">Auto Gestão</h3>
              <p className="text-gray-600 text-xs leading-relaxed">
                O cliente pode fechar a conta e realizar o pagamento sem precisar chamar o garçom.
              </p>
            </div>
          </div>
        </div>
      </section>

      <section className="py-24 bg-[#f8f8f8] border-y border-gray-200">
         <div className="container mx-auto px-8">
            <div className="flex flex-col md:flex-row items-center justify-between gap-16">
               <div className="md:w-1/2">
                  <span className="text-[#C5A47E] font-bold tracking-[0.2em] text-[10px] uppercase mb-3 block">Inovação</span>
                  <h2 className="text-3xl font-bold text-gray-900 mb-6 uppercase tracking-wide">Por que adotar?</h2>
                  <div className="space-y-6">
                     <div className="flex gap-4">
                        <div className="w-12 h-12 flex-shrink-0 bg-white shadow-sm flex items-center justify-center rounded-sm text-[#510006] font-bold text-xl">1</div>
                        <div>
                           <h4 className="font-bold text-sm uppercase tracking-wide mb-1">Redução de Custos</h4>
                           <p className="text-xs text-gray-600 leading-relaxed">Menor necessidade de garçons apenas para tirar pedidos, focando a equipe no atendimento consultivo e entrega.</p>
                        </div>
                     </div>
                     <div className="flex gap-4">
                        <div className="w-12 h-12 flex-shrink-0 bg-white shadow-sm flex items-center justify-center rounded-sm text-[#510006] font-bold text-xl">2</div>
                        <div>
                           <h4 className="font-bold text-sm uppercase tracking-wide mb-1">Giro de Mesa</h4>
                           <p className="text-xs text-gray-600 leading-relaxed">Sem espera para pedir ou pagar, o cliente consome mais rápido e libera a mesa para o próximo.</p>
                        </div>
                     </div>
                     <div className="flex gap-4">
                        <div className="w-12 h-12 flex-shrink-0 bg-white shadow-sm flex items-center justify-center rounded-sm text-[#510006] font-bold text-xl">3</div>
                        <div>
                           <h4 className="font-bold text-sm uppercase tracking-wide mb-1">Zero Erros</h4>
                           <p className="text-xs text-gray-600 leading-relaxed">O cliente marca exatamente o que quer (com ou sem cebola, ponto da carne, etc), eliminando devoluções.</p>
                        </div>
                     </div>
                  </div>
               </div>
               <div className="md:w-1/2 bg-white p-8 shadow-lg border-l-4 border-[#510006]">
                  <h3 className="text-xl font-bold text-[#510006] uppercase tracking-wide mb-6">O que está incluso</h3>
                  <ul className="space-y-4">
                     <li className="flex items-center text-sm text-gray-700">
                        <ChevronRight className="w-4 h-4 text-[#C5A47E] mr-2" />
                        Editor de Cardápio em Tempo Real
                     </li>
                     <li className="flex items-center text-sm text-gray-700">
                        <ChevronRight className="w-4 h-4 text-[#C5A47E] mr-2" />
                        Fotos Ilimitadas
                     </li>
                     <li className="flex items-center text-sm text-gray-700">
                        <ChevronRight className="w-4 h-4 text-[#C5A47E] mr-2" />
                        Categorias Personalizáveis
                     </li>
                     <li className="flex items-center text-sm text-gray-700">
                        <ChevronRight className="w-4 h-4 text-[#C5A47E] mr-2" />
                        Relatório de Pratos Mais Vendidos
                     </li>
                  </ul>
                  <div className="mt-8 pt-8 border-t border-gray-100">
                     <Link href="/#planos" className="block w-full text-center bg-[#1a1a1a] text-white py-4 text-xs font-bold uppercase tracking-widest hover:bg-[#510006] transition-colors rounded-sm">
                        Ver Planos Disponíveis
                     </Link>
                  </div>
               </div>
            </div>
         </div>
      </section>

      <footer className="bg-[#510006] text-white py-8 text-center border-t border-white/10">
        <div className="container mx-auto px-8 flex flex-col items-center">
            <Image
              src="/logo.svg"
              alt="Logo Techbistro"
              width={24}
              height={24}
              className="filter brightness-0 invert opacity-50 mb-4"
            />
            <p className="text-[10px] uppercase tracking-widest opacity-60">Techbistro &copy; {new Date().getFullYear()}</p>
        </div>
      </footer>
    </div>
  );
}