import Image from 'next/image';
import Link from 'next/link';
import { 
  Smartphone, 
  UtensilsCrossed, 
  CreditCard, 
  BarChart3, 
  Check, 
  MapPin, 
  Phone, 
  Mail, 
  Instagram, 
  Facebook, 
  Linkedin,
  ArrowRight,
  ChevronRight
} from 'lucide-react';

const Header = () => (
  <header className="relative w-full min-h-[85vh] flex flex-col text-white overflow-hidden">
    <div className="absolute inset-0 z-0">
      <img
        src="/images/fundo_restaurante.jpg"
        alt="Fundo Restaurante"
        className="w-full h-full object-cover scale-105 animate-slow-zoom"
      />
      <div className="absolute inset-0 bg-gradient-to-b from-black/90 via-black/40 to-black/90"></div>
    </div>
    
    <div className="relative z-20 container mx-auto px-8 flex-grow flex flex-col pt-6">
      
      {/* Navbar: Sem linha e com espaçamento lateral (justify-between) */}
      <nav className="w-full flex justify-center items-center">
        <div className="hidden md:flex w-full justify-between items-center max-w-5xl mx-auto">
          <Link href="/" className="text-xs uppercase tracking-[0.25em] hover:text-[#C5A47E] transition-all duration-300 font-medium text-gray-200 hover:text-white">Início</Link>
          <Link href="/cardapio" className="text-xs uppercase tracking-[0.25em] hover:text-[#C5A47E] transition-all duration-300 font-medium text-gray-200 hover:text-white">Cardápio</Link>
          <Link href="#planos" className="text-xs uppercase tracking-[0.25em] hover:text-[#C5A47E] transition-all duration-300 font-medium text-gray-200 hover:text-white">Planos</Link>
          <Link href="#contato" className="text-xs uppercase tracking-[0.25em] hover:text-[#C5A47E] transition-all duration-300 font-medium text-gray-200 hover:text-white">Contato</Link>
        </div>
        
        <div className="w-full flex justify-end items-center md:hidden">
          <button className="text-white p-2">
            <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="3" y1="12" x2="21" y2="12"></line><line x1="3" y1="6" x2="21" y2="6"></line><line x1="3" y1="18" x2="21" y2="18"></line></svg>
          </button>
        </div>
      </nav>

      <div className="flex-grow flex flex-col items-center justify-center text-center mt-[-20px]">
        
        <div className="mb-6">
           <Image
            src="/logo.svg"
            alt="Logo Techbistro"
            width={80}
            height={80}
            priority 
            className="drop-shadow-2xl opacity-100"
          />
        </div>

        <h1 className="text-3xl md:text-5xl font-bold tracking-[0.25em] uppercase drop-shadow-lg mb-4 text-white">
          Techbistro
        </h1>
        
        <div className="w-16 h-[2px] bg-[#C5A47E] mb-6"></div>
        
        <p className="text-gray-200 text-xs md:text-sm tracking-[0.3em] uppercase font-medium mb-10">
          Gestão Inteligente & Gastronomia
        </p>
        
        <Link href="#planos" className="group relative px-10 py-3 overflow-hidden border border-[#C5A47E] rounded-sm transition-all duration-300 hover:bg-[#C5A47E]/10">
          <div className="absolute inset-0 w-0 bg-[#C5A47E] transition-all duration-[250ms] ease-out group-hover:w-full opacity-20"></div>
          <span className="relative text-[11px] uppercase tracking-widest text-[#C5A47E] group-hover:text-white transition-colors font-bold">Conheça os Planos</span>
        </Link>
      </div>
    </div>
  </header>
);

const FeatureCard = ({ icon: Icon, title, description }: { icon: React.ElementType, title: string, description: string }) => (
  <div className="bg-white p-8 rounded-sm border border-gray-100 shadow-sm hover:shadow-xl transition-all duration-500 group hover:border-[#C5A47E]">
    <Icon className="w-8 h-8 text-[#C5A47E] mb-6 group-hover:scale-110 transition-transform duration-300" />
    <h3 className="text-sm font-bold text-gray-900 mb-3 uppercase tracking-widest">{title}</h3>
    <p className="text-sm text-gray-600 leading-relaxed font-normal">
      {description}
    </p>
  </div>
);

const PricingCard = ({ title, price, features, recommended, isFree }: { title: string, price: string, features: string[], recommended?: boolean, isFree?: boolean }) => (
  <div className={`flex flex-col p-8 bg-white transition-all duration-300 ${recommended ? 'shadow-2xl border-t-4 border-[#900000] scale-105 relative z-10' : 'border border-gray-200 hover:border-[#C5A47E] shadow-lg hover:shadow-xl'}`}>
    {recommended && (
      <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
        <span className="bg-[#900000] text-white text-[10px] font-bold px-4 py-1 uppercase tracking-widest shadow-sm rounded-b">Recomendado</span>
      </div>
    )}
    <div className="text-center mb-6 pt-2">
      <h3 className="text-xs font-bold text-[#C5A47E] uppercase tracking-[0.2em] mb-4">{title}</h3>
      <div className="flex items-center justify-center text-gray-900">
        <span className="text-xs font-medium mr-1">{isFree ? '' : 'R$'}</span>
        <span className="text-4xl font-bold">{price}</span>
        <span className="text-xs text-gray-500 ml-1">{isFree ? '' : '/mês'}</span>
      </div>
    </div>
    <div className="w-full h-[1px] bg-gray-100 mb-6"></div>
    <ul className="flex-1 space-y-4 mb-8">
      {features.map((feature, index) => (
        <li key={index} className="flex items-start text-gray-600 text-xs">
          <Check className="w-4 h-4 text-[#C5A47E] mr-3 flex-shrink-0" />
          <span className="leading-relaxed font-medium">{feature}</span>
        </li>
      ))}
    </ul>
    <button className={`w-full py-4 text-[10px] font-bold uppercase tracking-[0.2em] transition-all duration-300 rounded-sm ${recommended ? 'bg-[#1a1a1a] text-white hover:bg-[#900000]' : 'bg-gray-100 text-gray-700 hover:bg-[#C5A47E] hover:text-white'}`}>
      {isFree ? 'Começar Teste' : 'Selecionar Plano'}
    </button>
  </div>
);

export default function Home() {
  const features = [
    { icon: Smartphone, title: "Agilidade", description: "Reduza o tempo de espera com pedidos digitais instantâneos e intuitivos." },
    { icon: UtensilsCrossed, title: "Produção", description: "Conexão direta com a cozinha, eliminando erros manuais e desperdícios." },
    { icon: CreditCard, title: "Pagamentos", description: "Conciliação automática e múltiplas formas de pagamento integradas." },
    { icon: BarChart3, title: "Gestão", description: "Dados precisos para tomadas de decisão estratégicas em tempo real." },
  ];

  return (
    <div className="font-sans antialiased bg-white selection:bg-[#C5A47E] selection:text-white">
      <Header />
      
      <main>
        <section id="vantagens" className="py-24 bg-gray-50">
          <div className="container mx-auto px-8">
            <div className="flex flex-col md:flex-row justify-between items-end mb-16 pb-6 border-b border-gray-200">
              <div className="max-w-xl">
                <span className="text-[#C5A47E] font-bold tracking-[0.2em] text-[10px] uppercase mb-3 block">Diferenciais</span>
                <h2 className="text-2xl md:text-3xl font-bold text-gray-900 uppercase tracking-wide leading-tight">
                  Experiência Premium
                </h2>
              </div>
              <div className="hidden md:block pb-2">
                <Link href="#contato" className="text-xs font-bold text-[#900000] uppercase tracking-widest flex items-center hover:opacity-70 transition-opacity">
                  Saiba Mais <ArrowRight className="ml-2 w-4 h-4" />
                </Link>
              </div>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
              {features.map((feature, index) => (
                <FeatureCard key={index} {...feature} />
              ))}
            </div>
          </div>
        </section>

        <section id="servicos" className="py-24 bg-[#900000] text-white relative overflow-hidden">
          <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,rgba(255,255,255,0.1),transparent_50%)]"></div>
          <div className="container mx-auto px-8 relative z-10">
            <div className="flex flex-col md:flex-row items-center gap-16">
              <div className="w-full md:w-1/2">
                 <span className="text-[#C5A47E] font-bold tracking-[0.2em] text-[10px] uppercase mb-3 block">Ecossistema</span>
                 <h2 className="text-3xl md:text-4xl font-bold mb-6 leading-tight tracking-wide">Controle Total <br/><span className="text-white/60">do seu Negócio</span></h2>
                 <p className="text-gray-100 text-sm leading-loose mb-8 text-justify font-medium opacity-90">
                   Centralize toda a operação do seu restaurante em uma única plataforma. Do momento em que o cliente senta à mesa até o fechamento do caixa, nossa tecnologia trabalha silenciosamente para garantir excelência.
                 </p>
                 <div className="grid grid-cols-2 gap-4">
                    <div className="bg-white/10 p-6 border border-white/10 backdrop-blur-sm rounded-sm">
                      <h4 className="text-[#C5A47E] font-bold text-xl mb-1">40%</h4>
                      <p className="text-[10px] uppercase tracking-widest text-white font-semibold">Mais Agilidade</p>
                    </div>
                    <div className="bg-white/10 p-6 border border-white/10 backdrop-blur-sm rounded-sm">
                      <h4 className="text-[#C5A47E] font-bold text-xl mb-1">25%</h4>
                      <p className="text-[10px] uppercase tracking-widest text-white font-semibold">Aumento no Ticket</p>
                    </div>
                 </div>
              </div>
              <div className="w-full md:w-1/2 flex justify-center">
                <div className="relative w-full max-w-md aspect-video bg-gradient-to-tr from-black to-[#3a0000] rounded-lg shadow-2xl border border-white/10 flex items-center justify-center overflow-hidden group">
                  <div className="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1556742049-0cfed4f7a07d?auto=format&fit=crop&w=800&q=80')] bg-cover bg-center opacity-40 group-hover:scale-105 transition-transform duration-700"></div>
                  <div className="relative z-10 bg-black/50 p-6 backdrop-blur-md border border-white/20">
                     <p className="text-white text-xs tracking-[0.2em] uppercase font-bold">Dashboard Preview</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section id="planos" className="py-24 bg-white border-t border-gray-200">
          <div className="container mx-auto px-8">
            <div className="text-center mb-16">
              <span className="text-[#900000] font-bold tracking-[0.2em] text-[10px] uppercase mb-2 block">Investimento</span>
              <h2 className="text-2xl md:text-3xl font-bold text-gray-900 uppercase tracking-wide">
                Planos & Assinaturas
              </h2>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto items-center">
               <PricingCard 
                title="Trial" 
                price="Grátis" 
                isFree={true}
                features={[
                  "7 dias de acesso total",
                  "Funcionalidades Pro",
                  "Sem cartão de crédito",
                  "Suporte Básico"
                ]} 
              />
              
              <PricingCard 
                title="Professional" 
                price="299" 
                recommended={true}
                features={[
                  "Terminais ilimitados",
                  "QR Code Integrado",
                  "Integração Delivery",
                  "Gestão Financeira",
                  "Suporte 24h"
                ]} 
              />

              <PricingCard 
                title="Starter" 
                price="149" 
                features={[
                  "Até 2 terminais",
                  "Cardápio Digital",
                  "Relatórios básicos",
                  "Suporte Email"
                ]} 
              />
            </div>

            <div className="mt-16 text-center">
              <Link href="#" className="inline-flex items-center text-xs font-bold text-gray-500 hover:text-[#900000] transition-colors uppercase tracking-widest group">
                Comparar todos os recursos <ChevronRight className="ml-1 w-3 h-3 group-hover:translate-x-1 transition-transform" />
              </Link>
            </div>
          </div>
        </section>
      </main>
      
      {/* Footer em Vermelho conforme solicitado */}
      <footer id="contato" className="bg-[#900000] text-white pt-20 pb-8 border-t border-white/10">
        <div className="container mx-auto px-8">
          <div className="flex flex-col lg:flex-row justify-between gap-12 mb-16">
            
            <div className="lg:w-1/3 space-y-6">
              <div className="flex items-center gap-3">
                 <div className="w-10 h-10 bg-white/10 flex items-center justify-center rounded-sm backdrop-blur-sm">
                    <span className="font-serif font-bold text-white text-xl">T</span>
                 </div>
                 <span className="text-xl font-bold tracking-[0.2em] uppercase text-white">Techbistro</span>
              </div>
              <p className="text-white/80 text-sm leading-loose font-light max-w-xs">
                Transformando a gestão gastronômica com elegância e precisão tecnológica. Simplifique processos e amplie seus resultados.
              </p>
              <div className="flex gap-4">
                <a href="#" className="w-10 h-10 bg-white/10 flex items-center justify-center hover:bg-[#C5A47E] hover:text-white transition-all rounded-sm"><Instagram size={18} /></a>
                <a href="#" className="w-10 h-10 bg-white/10 flex items-center justify-center hover:bg-[#C5A47E] hover:text-white transition-all rounded-sm"><Linkedin size={18} /></a>
                <a href="#" className="w-10 h-10 bg-white/10 flex items-center justify-center hover:bg-[#C5A47E] hover:text-white transition-all rounded-sm"><Mail size={18} /></a>
              </div>
            </div>

            <div className="lg:w-2/3 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-8">
              <div>
                <h4 className="text-[10px] font-bold text-[#C5A47E] uppercase tracking-widest mb-6">Plataforma</h4>
                <ul className="space-y-3 text-sm text-white/80">
                  <li><Link href="/" className="hover:text-white transition-colors">Início</Link></li>
                  <li><Link href="/cardapio" className="hover:text-white transition-colors">Cardápio Digital</Link></li>
                  <li><Link href="#planos" className="hover:text-white transition-colors">Planos</Link></li>
                  <li><Link href="/login" className="hover:text-white transition-colors">Área do Cliente</Link></li>
                </ul>
              </div>

              <div>
                <h4 className="text-[10px] font-bold text-[#C5A47E] uppercase tracking-widest mb-6">Legal</h4>
                <ul className="space-y-3 text-sm text-white/80">
                  <li><Link href="#" className="hover:text-white transition-colors">Termos de Uso</Link></li>
                  <li><Link href="#" className="hover:text-white transition-colors">Privacidade</Link></li>
                  <li><Link href="#" className="hover:text-white transition-colors">Compliance</Link></li>
                </ul>
              </div>

              <div className="col-span-2 md:col-span-1">
                <h4 className="text-[10px] font-bold text-[#C5A47E] uppercase tracking-widest mb-6">Contato</h4>
                <ul className="space-y-4 text-sm text-white/80">
                  <li className="flex items-start">
                    <MapPin className="w-5 h-5 mr-3 text-[#C5A47E] flex-shrink-0" />
                    <span>Jardim Jose Ometto II<br/>Araras - SP, 13606-360</span>
                  </li>
                  <li className="flex items-center">
                    <Phone className="w-5 h-5 mr-3 text-[#C5A47E] flex-shrink-0" />
                    <span>(19) 97159-5745</span>
                  </li>
                  <li className="flex items-center">
                    <Mail className="w-5 h-5 mr-3 text-[#C5A47E] flex-shrink-0" />
                    <span>techbistro@gmail.com</span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          <div className="border-t border-white/10 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-[10px] text-white/50 uppercase tracking-widest">
              &copy; {new Date().getFullYear()} Techbistro. Todos os direitos reservados.
            </p>
            <div className="flex items-center gap-2 opacity-50 hover:opacity-100 transition-opacity">
               <CreditCard className="w-4 h-4" />
               <span className="text-[10px] font-medium">Pagamento Seguro</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}